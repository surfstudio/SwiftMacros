import SwiftSyntax

public extension Comparator {
    static func compare(_ lhs: FunctionSignatureSyntax, _ rhs: FunctionSignatureSyntax) -> Bool {
        guard 
            let lhsReturnClause = lhs.returnClause,
            let rhsReturnClause = rhs.returnClause
        else {
            return false
        }
        return compare(lhsReturnClause, rhsReturnClause)
    }
}
