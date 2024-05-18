//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

public protocol ReloadableAction: Equatable {
  static func reloading(_ action: ReloadingAction) -> Self
}

public enum ReloadingAction: Sendable {
  case reload
  case loaded
  case failed(Error)
}

public extension ReloadableAction {
  static var reload: Self {
    self.reloading(.reload)
  }
}

extension ReloadingAction: Equatable {
  public static func == (lhs: ReloadingAction, rhs: ReloadingAction) -> Bool {
    switch (lhs, rhs) {
    case (.reload, .reload), (.loaded, .loaded):
      return true

    case let (.failed(lhs), .failed(rhs)):
      return isEqual(lhs, rhs)

    case (_, _):
      return false
    }
  }
}
