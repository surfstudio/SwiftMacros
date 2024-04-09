import Foundation

public enum MacroError: Error {
    case emptyArgumentsList

    case missedGenericArgumentClause
    case emptyGenericArgumentList
}
