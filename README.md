# NamedClosure

A Swift macro that captures function and method calls as named closures with metadata.

This project was created with AI.

## What it does

The `#namedClosure` macro wraps a function or method call into a `NamedClosure` struct that contains:
- The function/method name
- The type (for instance methods) or `nil` (for free functions)
- A closure that executes the call

## Examples

### Instance Method

```swift
class MyClass {
    func doSomething() {
        print("Hello")
    }
}

let obj = MyClass()
let closure = #namedClosure(obj.doSomething())

print(closure.name)  // "doSomething"
print(closure.type)  // MyClass.self
closure.call()       // Executes obj.doSomething()
```

### Free Function

```swift
func processData() {
    print("Processing...")
}

let closure = #namedClosure(processData())

print(closure.name)  // "processData"
print(closure.type)  // nil
closure.call()       // Executes processData()
```

## Why it's useful

- **Delayed execution**: Capture calls to execute later
- **Debugging**: Track which methods are being called with their types
- **Callbacks with metadata**: Pass closures that include their source information
- **Testing**: Create test fixtures that know their own identity

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/joehinkle11/NamedClosure.git", from: "1.0.0")
]
```

## Requirements

- Swift 6.2+
- macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+, or macCatalyst 13+
