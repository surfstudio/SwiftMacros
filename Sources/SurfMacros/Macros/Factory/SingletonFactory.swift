/// Add implementation of basic functionallity for producing a singleton object of type `Product` into a type declaration.
///
/// - Warning: Implement the `produceProduct()` method that returns an object of type Product; this method should be defined in the type to which this macro is attached.
@attached(member, names: arbitrary)
public macro SingletonFactory<Product>() = #externalMacro(module: "SurfMacroBody", type: "SingletonFactoryMacro")
