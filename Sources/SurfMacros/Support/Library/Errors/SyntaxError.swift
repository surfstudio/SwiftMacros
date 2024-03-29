import SwiftSyntax

public enum SyntaxError: Error {
    case failedCastTo(type: Any.Type)
}
