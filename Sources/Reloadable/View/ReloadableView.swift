//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct ReloadableView<
  State,
  Path,
  Action: ReloadableAction,
  Content: View,
  IdleContent: View,
  LoadingContent: View,
  ErrorContent: View
>: View {
  public typealias RootState = ReloadableState<State, Path>
  public typealias RootAction = LoadingAction<State, Action>

  private let store: Store<RootState, RootAction>
  private let content: (Store<State, Action>) -> Content
  private let idleContent: IdleContent
  private let loadingContent: LoadingContent
  private let errorContent: (Store<Error, RootAction>) -> ErrorContent

  public init(
    _ store: Store<RootState, RootAction>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content,
    @ViewBuilder idle idleContent: () -> IdleContent,
    @ViewBuilder loading loadingContent: () -> LoadingContent,
    @ViewBuilder error errorContent: @escaping (Store<Error, RootAction>) -> ErrorContent
  ) {
    self.store = store
    self.content = content
    self.idleContent = idleContent()
    self.loadingContent = loadingContent()
    self.errorContent = errorContent
  }

  public var body: some View {
    WithPerceptionTracking {
      if let store = store.scope(state: \.value, action: \.other) {
        content(store)
      } else {
        conditionView()
      }
    }
    .task { @MainActor in
      await store.send(.load).finish()
    }
  }
}

private extension ReloadableView {
  @ViewBuilder
  private func conditionView() -> some View {
    switch store.loading.condition {
    case .idle:
      idleContent

    case .loading:
      loadingContent

    case .error:
      if let store = store.scope(
        state: \.loading.condition.error,
        action: \.self
      ) {
        errorContent(store)
      }
    }
  }
}
