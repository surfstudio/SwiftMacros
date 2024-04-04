import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: IdentifierTypeSyntax, _ rhs: IdentifierTypeSyntax) -> Bool {
        return compare(lhs.name, rhs.name)
    }
}
