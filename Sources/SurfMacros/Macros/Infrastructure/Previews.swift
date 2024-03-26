import SwiftUI

@freestanding(declaration, names: named(Content_Previews))
public macro Previews(@ViewBuilder _ body: @escaping () -> any View) = #externalMacro(module: "SurfMacroBody", type: "PreviewsMacro")
