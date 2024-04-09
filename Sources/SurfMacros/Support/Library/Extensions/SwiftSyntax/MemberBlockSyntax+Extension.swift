import SwiftSyntax

public extension MemberBlockSyntax {

    var functionDecls: [FunctionDeclSyntax] {
        decls(of: FunctionDeclSyntax.self)
    }

    var enumDecls: [EnumDeclSyntax] {
        decls(of: EnumDeclSyntax.self)
    }

}

// MARK: - Private Methods

private extension MemberBlockSyntax {

    func decls<T: DeclSyntaxProtocol>(of type: T.Type) -> [T] {
        return members.compactMap { $0.decl.as(type) }
    }

}
