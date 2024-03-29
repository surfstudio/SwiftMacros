import SwiftSyntax

public extension TokenSyntax {
    init(_ kind: TokenKind) {
        self.init(kind, presence: .present)
    }
}
