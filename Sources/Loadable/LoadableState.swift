//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

@ObservableState
@CasePathable
@dynamicMemberLookup
public enum LoadableState<Value, Path> {
  case initial(LoadingState<Path>)
  case value(Value)
}

extension LoadableState where Path == EmptyLoadingPath {
  public static var initial: Self {
    .initial(.initial)
  }
}

extension LoadableState: Equatable where Value: Equatable, Path: Equatable {}
extension LoadableState: Sendable where Value: Sendable, Path: Sendable {}
