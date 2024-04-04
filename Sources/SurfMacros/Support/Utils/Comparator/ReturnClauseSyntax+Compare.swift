import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: ReturnClauseSyntax, _ rhs: ReturnClauseSyntax) -> Bool {
        guard
            let lhsIdentifier = lhs.type.as(IdentifierTypeSyntax.self),
            let rhsIdentifier = rhs.type.as(IdentifierTypeSyntax.self)
        else {
            return false
        }
        return compare(lhsIdentifier, rhsIdentifier)
    }
}
