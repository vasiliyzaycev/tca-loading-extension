//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

extension Reducer {
  public func loadable<Path>(
    loadState: @escaping @Sendable (Path) async throws -> State
  ) -> some Reducer<
    LoadableState<State, Path>,
    LoadingAction<State, Action>
  > {
    Loadable(wrapped: self, loadState: loadState)
  }

  public func loadable(
    loadState: @escaping @Sendable () async throws -> State
  ) -> some Reducer<
    LoadableState<State, EmptyLoadingPath>,
    LoadingAction<State, Action>
  > {
    Loadable(wrapped: self, loadState: { _ in try await loadState() })
  }
}
