/// Declares a class for general signal object that contains both inner module signals and ones set by user
/// - Warning: Can be attached to a protocol only.
/// - Warning: `SurfCore` module import is required. Don't forget to add it as a dependency in the manifest as well.
@attached(peer, names: suffixed(s))
public macro Multicast() = #externalMacro(module: "SurfMacroBody", type: "MulticastMacro")
