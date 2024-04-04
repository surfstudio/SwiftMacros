import SwiftSyntax

public extension FunctionCallExprSyntax {
    init(calledExpression: ExprSyntaxProtocol, arguments: LabeledExprListSyntax = []) {
        self.init(
            calledExpression: calledExpression,
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )
    }
}
