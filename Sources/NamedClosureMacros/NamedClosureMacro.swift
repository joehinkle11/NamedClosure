import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `namedClosure` macro, which takes a function or method call
/// and produces a `NamedClosure` instance containing the name, type, and call.
///
/// Supports:
/// - Instance method calls: `obj.method(args)` -> extracts method name and object type
/// - Free function calls: `function(args)` -> extracts function name, type is nil
public struct NamedClosureMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            // For now, just return an error expression - diagnostics can be added later
            return ExprSyntax(stringLiteral: "NamedClosure(name: \"\", type: nil, call: {})")
        }
        
        // Try to parse as a function call
        if let functionCall = argument.as(FunctionCallExprSyntax.self) {
            return expandFunctionCall(functionCall, in: context)
        }
        
        // Try to parse as a member access (property or method without call)
        if argument.as(MemberAccessExprSyntax.self) != nil {
            // This is a property access or method reference without call - error case
            return ExprSyntax(stringLiteral: "NamedClosure(name: \"\", type: nil, call: {})")
        }
        
        // Unsupported expression type
        return ExprSyntax(stringLiteral: "NamedClosure(name: \"\", type: nil, call: {})")
    }
    
    private static func expandFunctionCall(
        _ functionCall: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        // Check if this is a member access call (instance method)
        if let memberAccess = functionCall.calledExpression.as(MemberAccessExprSyntax.self) {
            return expandInstanceMethod(memberAccess, functionCall: functionCall, in: context)
        }
        
        // Check if this is a direct identifier call (free function)
        if let identifier = functionCall.calledExpression.as(DeclReferenceExprSyntax.self) {
            return expandFreeFunction(identifier, functionCall: functionCall, in: context)
        }
        
        // Unsupported call type
        return ExprSyntax(stringLiteral: "NamedClosure(name: \"\", type: nil, call: {})")
    }
    
    private static func expandInstanceMethod(
        _ memberAccess: MemberAccessExprSyntax,
        functionCall: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let base = memberAccess.base else {
            return ExprSyntax(stringLiteral: "NamedClosure(name: \"\", type: nil, call: {})")
        }
        
        let methodName = memberAccess.declName.baseName.text
        
        // Reconstruct the full call expression
        let fullCall = "\(base.description).\(methodName)(\(functionCall.arguments))"
        
        // Build the NamedClosure expression
        return """
        NamedClosure(
            name: \(literal: methodName),
            type: type(of: \(raw: base)),
            call: { \(raw: fullCall) }
        )
        """
    }
    
    private static func expandFreeFunction(
        _ identifier: DeclReferenceExprSyntax,
        functionCall: FunctionCallExprSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        let functionName = identifier.baseName.text
        
        // Reconstruct the full call expression
        let fullCall = "\(functionName)(\(functionCall.arguments))"
        
        return """
        NamedClosure(
            name: \(literal: functionName),
            type: nil,
            call: { \(raw: fullCall) }
        )
        """
    }
}

@main
struct NamedClosurePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NamedClosureMacro.self,
    ]
}
