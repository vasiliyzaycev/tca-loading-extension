//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

public struct DefaultErrorView<State, Action>: View {
  public typealias RootAction = LoadingAction<State, Action>

  private let store: Store<Error, RootAction>

  public init(store: Store<Error, RootAction>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      VStack {
        Text("Error")
        Button {
          store.send(.reload)
        } label: {
          Text("Retry")
        }
      }
    }
  }
}
