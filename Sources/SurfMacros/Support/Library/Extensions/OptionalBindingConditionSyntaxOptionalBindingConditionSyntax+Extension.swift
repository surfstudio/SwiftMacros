import SwiftSyntax

public extension OptionalBindingConditionSyntax {
    init(pattern: PatternSyntaxProtocol, initializer: InitializerClauseSyntax) {
        self.init(bindingSpecifier: .keyword(.let), pattern: pattern, initializer: initializer)
    }
}
