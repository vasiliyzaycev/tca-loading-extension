//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

extension Reducer where Action: ReloadableAction {
  public func reloadable<Path>(
    loadState: @escaping @Sendable (Path) async throws -> State
  ) -> some Reducer<
    ReloadableState<State, Path>,
    LoadingAction<State, Action>
  > {
    Reloadable(wrapped: self, loadState: loadState)
  }

  public func reloadable(
    loadState: @escaping @Sendable () async throws -> State
  ) -> some Reducer<
    ReloadableState<State, EmptyLoadingPath>,
    LoadingAction<State, Action>
  > {
    Reloadable(wrapped: self, loadState: { _ in try await loadState() })
  }
}
