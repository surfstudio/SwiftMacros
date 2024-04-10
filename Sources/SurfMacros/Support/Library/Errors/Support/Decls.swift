import Foundation

public enum Decls: String, CustomStringConvertible {
    case `protocol`
    case `class`
    case `struct`
    case `func`
    case `enum`

    public var description: String {
        self.rawValue
    }
}
