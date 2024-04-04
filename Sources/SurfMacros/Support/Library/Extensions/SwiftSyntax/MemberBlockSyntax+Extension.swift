import SwiftSyntax

public extension MemberBlockSyntax {
    var functionDecls: [FunctionDeclSyntax] {
        members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
}
