import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SurfMacroBody)
import SurfMacroBody

// uncomment the line bellow when there is an implementation of the macro
// private let testMacros: [String: Macro.Type] = ["navigationstate": NavigationStateMacro.self]
#endif

final class NavigationStateMacroTests: XCTestCase {}
