//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

import ComposableArchitecture

public typealias LoadingActionOf<R: Reducer> = LoadingAction<R.State, R.Action>

@CasePathable
public enum LoadingAction<Value, Action> {
  case load
  case reload
  case loaded(Value)
  case failed(Error)
  case other(Action)
}

@ObservableState
public struct LoadingState<Path> {
  public var condition: LoadingCondition
  public var path: Path
}

@ObservableState
@CasePathable
@dynamicMemberLookup
public enum LoadingCondition: Sendable {
  case idle
  case loading
  case error(Error)
}

public struct EmptyLoadingPath: Equatable, Sendable {}

extension LoadingState where Path == EmptyLoadingPath {
  public static var initial: Self {
    .init(condition: .idle, path: EmptyLoadingPath())
  }
}

extension LoadingState {
  public static func initial(with path: Path) -> Self {
    .init(condition: .idle, path: path)
  }

  public func with(condition newCondition: LoadingCondition) -> Self {
    .init(condition: newCondition, path: path)
  }
}

extension LoadingState: Equatable where Path: Equatable {}
extension LoadingState: Sendable where Path: Sendable {}

extension LoadingAction {
  public func map<NewValue, NewAction>(
    value transformValue: (Value) -> NewValue,
    action transformAction: (Action) -> NewAction
  ) -> LoadingAction<NewValue, NewAction> {
    switch self {
    case .load:               .load
    case .reload:             .reload
    case .loaded(let value):  .loaded(transformValue(value))
    case .failed(let error):  .failed(error)
    case .other(let action):  .other(transformAction(action))
    }
  }
}

extension LoadingAction: Sendable where Value: Sendable, Action: Sendable {}

extension LoadingAction: Equatable where Value: Equatable, Action: Equatable {
  public static func == (lhs: LoadingAction, rhs: LoadingAction) -> Bool {
    switch (lhs, rhs) {
    case (.load, .load), (.reload, .reload):
      return true

    case let (.failed(lhs), .failed(rhs)):
      return isEqual(lhs, rhs)

    case let (.other(lhs), .other(rhs)):
      return lhs == rhs

    case (_, _):
      return false
    }
  }
}

extension LoadingCondition: Equatable {
  public static func == (lhs: LoadingCondition, rhs: LoadingCondition) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.loading, .loading):
      return true

    case let (.error(lhs), .error(rhs)):
      return isEqual(lhs, rhs)

    case (_, _):
      return false
    }
  }
}
