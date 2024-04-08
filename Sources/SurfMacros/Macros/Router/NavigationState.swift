/// Fullfill a navigation struct with methods and fields used for routing.
/// - `navigationPath` - represents a navigation path
/// - `initial` - returns a new object of the struct with a initial stated path
/// - `push(destination: Destination)` - adds a destination to the path
/// - `pop()` - removes the top destination from the path
/// - `popToRoot()` - reverts the path to the initial state
/// - Warning: Can be attached to a struct only.
/// - Warning: The macro requires implementation of a nested `Destination` enum.
@attached(member, names: arbitrary)
public macro NavigationState() = #externalMacro(module: "SurfMacroBody", type: "NavigationStateMacro")
