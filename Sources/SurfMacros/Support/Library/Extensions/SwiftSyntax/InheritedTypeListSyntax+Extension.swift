import SwiftSyntax

public extension InheritedTypeListSyntax {
    func contains(type identifier: TokenSyntax) -> Bool {
        return !self
            .compactMap { $0.type.as(IdentifierTypeSyntax.self) }
            .filter { $0.name.text == identifier.text }
            .isEmpty
    }
}
