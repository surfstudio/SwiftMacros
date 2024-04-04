import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: DeclModifierListSyntax, _ rhs: DeclModifierListSyntax) -> Bool {
        return lhs.count == rhs.count && lhs.indices.map { compare(lhs[$0], rhs[$0]) }.filter { !$0 }.count == .zero
    }
}
