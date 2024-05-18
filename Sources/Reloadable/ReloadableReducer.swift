//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct Reloadable<Wrapped: Reducer, Path>
where Wrapped.Action: ReloadableAction {
  typealias State = ReloadableState<Wrapped.State, Path>
  typealias Action = LoadingAction<Wrapped.State, Wrapped.Action>

  let wrapped: Wrapped
  let loadState: @Sendable (Path) async throws -> Wrapped.State

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .load:                     return loadEffect(&state)
      case .reload, .other(.reload):  return reloadEffect(&state)
      case .loaded(let loadedValue):  return loadedEffect(&state, loadedValue)
      case .failed(let error):        return errorEffect(&state, error)
      case .other:                    return .none
      }
    }
    .ifLet(\.value, action: \.other) {
      wrapped
    }
  }
}

private extension Reloadable {
  private enum CancelId { case loading }

  private func loadEffect(_ state: inout State) -> Effect<Action> {
    guard state.loading.condition == .idle, state.value == nil else { return .none }
    return loadingEffect(&state)
  }

  private func reloadEffect(_ state: inout State) -> Effect<Action> {
    guard state.loading.condition != .loading else { return .none }
    return loadingEffect(&state)
  }

  private func loadingEffect(_ state: inout State) -> Effect<Action> {
    state.loading.condition = .loading
    return .run { @MainActor [path = state.loading.path] send in
      send(.loaded(try await loadState(path)))
    } catch: { @MainActor error, send in
      send(.failed(error))
    }
    .cancellable(id: CancelId.loading, cancelInFlight: true)
  }

  private func loadedEffect(
    _ state: inout State,
    _ loadedValue: Wrapped.State
  ) -> Effect<Action> {
    state.value = loadedValue
    state.loading.condition = .idle
    return .send(.other(.reloading(.loaded)))
  }

  private func errorEffect(
    _ state: inout State,
    _ error: Error
  ) -> Effect<Action> {
    state.loading.condition = .error(error)
    return state.value != nil ?
      .send(.other(.reloading(.failed(error)))) :
      .none
  }
}
