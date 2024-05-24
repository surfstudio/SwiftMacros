/// Declares a class for general signal object that contains both inner module signals and ones set by user
/// - Warning: Can be attached to a protocol only.
/// - Warning: There must be `defaultSignals: [<SignalProtocol>]` property that contains inner module signals nearby the protocol declaration the macro attached to.
@attached(peer, names: suffixed(s))
public macro Multicast() = #externalMacro(module: "SurfMacroBody", type: "MulticastMacro")
