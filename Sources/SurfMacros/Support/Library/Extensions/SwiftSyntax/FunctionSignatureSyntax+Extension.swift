import SwiftSyntax

public extension FunctionSignatureSyntax {
    init(returnClause: ReturnClauseSyntax) {
        self.init(parameterClause: .init(parameters: []), returnClause: returnClause)
    }
}
