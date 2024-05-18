//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct Loadable<Wrapped: Reducer, Path> {
  typealias State = LoadableState<Wrapped.State, Path>
  typealias Action = LoadingAction<Wrapped.State, Wrapped.Action>

  let wrapped: Wrapped
  let loadState: @Sendable (Path) async throws -> Wrapped.State

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .load:                     return loadEffect(&state)
      case .reload:                   return reloadEffect(&state)
      case .loaded(let loadedValue):  return loadedEffect(&state, loadedValue)
      case .failed(let error):        return errorEffect(&state, error)
      case .other:                    return .none
      }
    }
    .ifCaseLet(\.value, action: \.other) {
      wrapped
    }
  }
}

private extension Loadable {
  private func loadEffect(_ state: inout State) -> Effect<Action> {
    guard case .initial(let loadingState) = state,
          loadingState.condition == .idle else { return .none }
    return loadingEffect(&state, loadingState)
  }

  private func reloadEffect(_ state: inout State) -> Effect<Action> {
    guard case .initial(let loadingState) = state,
          loadingState.condition != .loading else { return .none }
    return loadingEffect(&state, loadingState)
  }

  private func loadingEffect(
    _ state: inout State,
    _ loadingState: LoadingState<Path>
  ) -> Effect<Action> {
    state = .initial(loadingState.with(condition: .loading))
    return .run { [path = loadingState.path] send in
      await send(.loaded(try await loadState(path)))
    } catch: { error, send in
      await send(.failed(error))
    }
  }

  private func loadedEffect(
    _ state: inout State,
    _ loadedValue: Wrapped.State
  ) -> Effect<Action> {
    state = .value(loadedValue)
    return .none
  }

  private func errorEffect(_ state: inout State, _ error: Error) -> Effect<Action> {
    guard case .initial(let loadingState) = state else { return .none }
    state = .initial(loadingState.with(condition: .error(error)))
    return .none
  }
}
