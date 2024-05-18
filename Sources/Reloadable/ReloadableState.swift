//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

@ObservableState
public struct ReloadableState<Value, Path> {
  public var loading: LoadingState<Path>
  public var value: Value?

  public init(loading: LoadingState<Path>, value: Value?) {
    self.loading = loading
    self.value = value
  }
}

extension ReloadableState {
  public static func initial(with path: Path) -> Self {
    .init(loading: .initial(with: path), value: nil)
  }
}

extension ReloadableState where Path == EmptyLoadingPath {
  public static var initial: Self {
    .init(loading: .initial, value: nil)
  }
}

extension ReloadableState: Equatable where Value: Equatable, Path: Equatable {}
extension ReloadableState: Sendable where Value: Sendable, Path: Sendable {}
