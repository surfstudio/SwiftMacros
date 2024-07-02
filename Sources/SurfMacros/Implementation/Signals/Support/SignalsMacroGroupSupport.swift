//
//  SignalsMacroGroupSupport.swift
//
//
//  Created by pavlov on 01.07.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

struct SignalsMacroGroupSupport {}

// MARK: - Checks

extension SignalsMacroGroupSupport {

    static func checkProtocolDeclaration(_ declaration: ProtocolDeclSyntax) throws {
        try checkMembers(of: declaration)
    }

}

// MARK: - Creations

extension SignalsMacroGroupSupport {

    static func createFuncDecl(
        from protocolFuncDecl: FunctionDeclSyntax,
        with body: CodeBlockSyntax,
        modifiers: DeclModifierListSyntax = []
    ) -> FunctionDeclSyntax {
        var funcDecl = protocolFuncDecl.trimmed
        funcDecl.body = body
        funcDecl.modifiers = modifiers
        return funcDecl
    }

}

// MARK: - Private Methods

private extension SignalsMacroGroupSupport {

    static func checkMembers(of decl: ProtocolDeclSyntax) throws {
        try decl.memberBlock.members.forEach { member in
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self),
               !isAppropriateFuncDecl(funcDecl) {
                throw CustomError(
                    description: """
                    The only allowed format of a function is the following:
                        func <name>(<argument>, ...)
                    """
                )
            } else if member.decl.is(VariableDeclSyntax.self) {
                throw DeclarationError.unexpectedVariable
            } else if member.decl.is(AssociatedTypeDeclSyntax.self) {
                throw DeclarationError.unexpectedAssociatedType
            }
        }
    }

    static func isAppropriateFuncDecl(_ decl: FunctionDeclSyntax) -> Bool {
        if !decl.modifiers.contains(where: isStatic),
           case .identifier = decl.name.tokenKind,
           decl.signature.returnClause == nil,
           decl.signature.effectSpecifiers == nil,
           decl.genericWhereClause == nil,
           decl.genericParameterClause == nil,
           decl.attributes.isEmpty {
            return true
        }
        return false
    }

    static func isStatic(_ modifier: DeclModifierSyntax) -> Bool {
        modifier.name.tokenKind == .keyword(.static)
    }

}
