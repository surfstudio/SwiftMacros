import SwiftUI
/// ⛔️ DOES NOT WORK⛔️ Declare the preview struct for SwiftUI views.
///
/// - Parameters:
///   - body: A ViewBuilder that produces a SwiftUI view to preview. You typically specify one of your app’s custom views and optionally any inputs, model data, modifiers, and enclosing views that the custom view needs for normal operation.
///
/// Unlike the original [`#Preview`](https://developer.apple.com/documentation/developertoolssupport/preview) macro, this implementation creates a preview for each view contained within the view builder.

@freestanding(declaration, names: named(Previews))
public macro Previews(@ViewBuilder _ body: @escaping @MainActor () -> any View) = #externalMacro(
    module: "SurfMacroBody",
    type: "PreviewsMacro"
)
