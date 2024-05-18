//
// Copyright © 2024 Vasiliy Zaycev. All rights reserved.
//

@_spi(RuntimeWarn)
import SwiftUINavigationCore

func isEqual(
  _ lhs: Any,
  _ rhs: Any,
  file: StaticString = #file,
  line: UInt = #line
) -> Bool {
  (lhs as? any Equatable)?.isEqual(other: rhs) ?? {
    #if DEBUG
    let lhsType = type(of: lhs)
    if lhsType == type(of: rhs) {
      let lhsTypeName = typeName(lhsType)
      runtimeWarn(
        """
        "\(lhsTypeName)" is not equatable. …

        To test two values of this type, it must conform to the "Equatable" protocol. For \
        example:

            extension \(lhsTypeName): Equatable {}
        """,
        category: nil,
        file: file,
        line: line
      )
    }
    #endif
    return false
  }()
}

private extension Equatable {
  func isEqual(other: Any) -> Bool {
    self == other as? Self
  }
}

#if DEBUG
func typeName(_ type: Any.Type) -> String {
  var name = _typeName(type, qualified: true)
  if let index = name.firstIndex(of: ".") {
    name.removeSubrange(...index)
  }
  let sanitizedName =
    name
    .replacingOccurrences(
      of: #"<.+>|\(unknown context at \$[[:xdigit:]]+\)\."#,
      with: "",
      options: .regularExpression
    )
  return sanitizedName
}
#endif
