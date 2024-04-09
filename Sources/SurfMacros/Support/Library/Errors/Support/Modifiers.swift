import Foundation

public enum Modifiers: String, CustomStringConvertible {
    case `private`

    public var description: String {
        self.rawValue
    }
}
