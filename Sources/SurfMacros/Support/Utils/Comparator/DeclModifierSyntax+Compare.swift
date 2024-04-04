import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: DeclModifierSyntax, _ rhs: DeclModifierSyntax) -> Bool {
        return compare(lhs.name, rhs.name)
    }
}
