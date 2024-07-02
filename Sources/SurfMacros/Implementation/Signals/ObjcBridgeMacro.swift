import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SurfMacrosSupport

public struct ObjcBridgeMacro: PeerMacro {

    // MARK: - Names

    private enum Names {
        static let nsObject = "NSObject"
        static let entity = "entity"

        static var declaration = ""
        static var bridgeClass: String {
            return declaration + "ObjcBridge"
        }
    }

    // MARK: - Macro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try checkDeclaration(declaration)
        let declarationName = try getDeclarationName(declaration)
        Names.declaration = declarationName.text
        let bridgeClass = createBridgeClass(with: declarationName)
        return [.init(bridgeClass)]
    }

}

// MARK: - Checks

private extension ObjcBridgeMacro {

    static func checkDeclaration(_ declaration: some DeclSyntaxProtocol) throws {
        let error = CustomError(description:  "Generic types cannot be represented in objc.")
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            if structDecl.genericParameterClause != nil {
                throw error
            }
        }
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            if classDecl.genericParameterClause != nil {
                throw error
            }
        }
        if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            if enumDecl.genericParameterClause != nil {
                throw error
            }
        }
    }

}

// MARK: - Getters

 private extension ObjcBridgeMacro {

     static func getDeclarationName(_ declaration: some DeclSyntaxProtocol) throws -> TokenSyntax {
         if let structDecl = declaration.as(StructDeclSyntax.self) {
             return structDecl.name
         }
         if let classDecl = declaration.as(ClassDeclSyntax.self) {
             return classDecl.name
         }
         if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
             return protocolDecl.name
         }
         if let enumDecl = declaration.as(EnumDeclSyntax.self) {
             return enumDecl.name
         }
         throw DeclarationError.wrongAttaching(expected: [.class, .struct, .enum, .protocol])
     }

 }

// MARK: - Creations

 private extension ObjcBridgeMacro {

     static func createBridgeClass(with name: TokenSyntax) -> ClassDeclSyntax {
         let publicModifier = createPublicModifier()
         let nsObjectInheritance = createNSObjectInheritance()
         let memberBlock = createBridgeClassMemberBlock()
         return .init(
            modifiers: [publicModifier],
            name: .identifier(Names.bridgeClass),
            inheritanceClause: nsObjectInheritance,
            memberBlock: memberBlock
         )
     }

     static func createNSObjectInheritance() -> InheritanceClauseSyntax {
         let nsObjectType = IdentifierTypeSyntax(name: .identifier(Names.nsObject))
         return .init(inheritedTypes: [.init(type: nsObjectType)])
     }

     static func createBridgeClassMemberBlock() -> MemberBlockSyntax {
         let itemList = MemberBlockItemListSyntax {
             createEntityProperty()
             createInit()
         }
         return .init(members: itemList)
     }

     static func createEntityProperty() -> VariableDeclSyntax {
         let publicModifier = createPublicModifier()

         let pattern = IdentifierPatternSyntax(identifier: .identifier(Names.entity))
         let type = TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier(Names.declaration)))
         let patternBinding = PatternBindingSyntax(pattern: pattern, typeAnnotation: type)

         return .init(
            modifiers: [publicModifier],
            bindingSpecifier: .keyword(.let),
            bindings: [patternBinding]
         )
     }

     static func createInit() -> InitializerDeclSyntax {
         let publicModifier = createPublicModifier()
         let signature = createInitSignature()
         let body = createInitBody()
         return .init(modifiers: [publicModifier], signature: signature, body: body)
     }

     static func createInitSignature() -> FunctionSignatureSyntax {
         let entityParameter = createEntityParameter()
         return .init(parameterClause: .init(parameters: [entityParameter]))
     }

     static func createEntityParameter() -> FunctionParameterSyntax {
         return .init(
            firstName: .wildcardToken(),
            secondName: .identifier(Names.entity),
            type: IdentifierTypeSyntax(name: .identifier(Names.declaration))
         )
     }

     static func createInitBody() -> CodeBlockSyntax {
         let selfEntity = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
            declName: .init(baseName: .identifier(Names.entity))
         )
         let entityParameter = DeclReferenceExprSyntax(baseName: .identifier(Names.entity))
         let entityAssignment = InfixOperatorExprSyntax(
            leftOperand: selfEntity,
            operator: AssignmentExprSyntax(),
            rightOperand: entityParameter
         )
         return .init(statements: [.init(item: .expr(.init(entityAssignment)))])
     }

     static func createPublicModifier() -> DeclModifierSyntax {
         return .init(name: .keyword(.public))
     }

 }
