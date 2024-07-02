import Foundation

public enum Decls: String, CustomStringConvertible, CaseIterable {
    case `protocol`
    case `class`
    case `struct`
    case `func`
    case `enum`

    public var description: String {
        self.rawValue
    }
}
