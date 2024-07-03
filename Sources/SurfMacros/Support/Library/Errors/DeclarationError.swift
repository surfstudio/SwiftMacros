import Foundation
import SwiftSyntax

public enum DeclarationError: Error, CustomStringConvertible {
    case wrongAttaching(expected: [Decls])
    case missedModifier(decl: Decls, declName: String, expected: Modifiers)
    case missedInheritance(decl: Decls, declName: String, expected: String)
    case unexpectedAssociatedType
    case unexpectedVariable
    case unexpectedParameterClause

    public var description: String {
        switch self {
        case .wrongAttaching(let expectedDecl):
            return "Macro can be attached to \(expectedDecl) only"
        case .missedModifier(let decl, let declName, let expectedModifier):
            return "\(decl) \(declName) must be \(expectedModifier)"
        case .missedInheritance(let decl, let declName, let expectedInheritance):
            return "\(decl) \(declName) must inherit from \(expectedInheritance)"
        case .unexpectedAssociatedType:
            return "There should not be any associated types"
        case .unexpectedVariable:
            return "There should not be any variables"
        case .unexpectedParameterClause:
            return "There should not be any parameter clause"
        }
    }
}
