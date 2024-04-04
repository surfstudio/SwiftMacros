import SwiftSyntax

public extension IfExprSyntax {
    init(conditions: ConditionElementListSyntax, body: CodeBlockSyntax, elseBody: ElseBody) {
        self.init(conditions: conditions, body: body, elseKeyword: .keyword(.else), elseBody: elseBody)
    }
}
