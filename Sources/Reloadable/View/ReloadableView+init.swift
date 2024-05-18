//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

extension ReloadableView {
  public init(
    _ store: Store<RootState, RootAction>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content
  ) where IdleContent == ProgressView<EmptyView, EmptyView>,
          LoadingContent == ProgressView<EmptyView, EmptyView>,
          ErrorContent == DefaultErrorView<State, Action> {
    self.init(
      store,
      content: content,
      error: { errorStore in
        DefaultErrorView(store: errorStore)
      }
    )
  }

  public init(
    _ store: Store<RootState, RootAction>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content,
    @ViewBuilder error errorContent: @escaping (Store<Error, RootAction>) -> ErrorContent
  ) where
      IdleContent == ProgressView<EmptyView, EmptyView>,
      LoadingContent == ProgressView<EmptyView, EmptyView> {
    self.init(
      store,
      content: content,
      loading: ProgressView.init,
      error: errorContent
    )
  }

  public init(
    _ store: Store<RootState, RootAction>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content,
    @ViewBuilder loading loadingContent: () -> LoadingContent,
    @ViewBuilder error errorContent: @escaping (Store<Error, RootAction>) -> ErrorContent
  ) where IdleContent == ProgressView<EmptyView, EmptyView> {
    self.init(
      store,
      content: content,
      idle: ProgressView.init,
      loading: loadingContent,
      error: errorContent
    )
  }
}
