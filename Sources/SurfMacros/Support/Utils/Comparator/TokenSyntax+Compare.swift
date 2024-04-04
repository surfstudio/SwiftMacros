import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: TokenSyntax, _ rhs: TokenSyntax) -> Bool {
        return lhs.kind == rhs.kind && lhs.presence == rhs.presence
    }
}
