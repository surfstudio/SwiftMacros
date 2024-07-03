@attached(peer, names: suffixed(ObjcBridge))
public macro ObjcBridge() = #externalMacro(module: "SurfMacroBody", type: "ObjcBridgeMacro")
