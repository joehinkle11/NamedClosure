/// A struct that represents a named closure, capturing a function or method call
/// with its name, type context, and executable call.
///
/// Use the `#namedClosure` macro to create instances of this type from function calls.
///
/// Example usage:
/// ```swift
/// let closure = #namedClosure(obj.doSomething(...))
/// // closure.name == "doSomething"
/// // closure.type == MyClass.self (or inferred type)
/// // closure.call() executes obj.doSomething(...)
/// ```
public struct NamedClosure<R> {
    /// The name of the function or method
    public let name: String
    
    /// The type of the instance for methods, or `nil` for free functions
    public let type: Any.Type?
    
    /// A closure that wraps the function call
    public let call: () -> R
    
    /// Initializes a NamedClosure with the required fields
    /// - Parameters:
    ///   - name: The function or method name
    ///   - type: The type of the instance for methods, or `nil` for free functions
    ///   - call: The closure wrapping the function call
    public init(
        name: String,
        type: Any.Type?,
        call: @escaping () -> R
    ) {
        self.name = name
        self.type = type
        self.call = call
    }

    /// The type of the closure as a string, or `nil` for free functions
    public var typeString: String? {
        return type.map { String(describing: $0) }
    }

    /// The name of the closure as a string
    public var typeAndNameString: String {
        if let type = type {
            return "\(type).\(name)"
        }
        return name
    }
}

/// A macro that creates a `NamedClosure` from a function or method call.
///
/// The macro accepts either:
/// - Instance method calls: `#namedClosure(obj.method(args))`
/// - Free function calls: `#namedClosure(function(args))`
///
/// Example:
/// ```swift
/// let closure = #namedClosure(myObject.doSomething(...))
/// print(closure.name) // "doSomething"
/// print(closure.type) // "MyClass" or inferred type
/// closure.call() // Executes myObject.doSomething(...)
/// ```
@freestanding(expression)
public macro namedClosure<R>(_ expression: R) -> NamedClosure<R> = #externalMacro(module: "NamedClosureMacros", type: "NamedClosureMacro")
