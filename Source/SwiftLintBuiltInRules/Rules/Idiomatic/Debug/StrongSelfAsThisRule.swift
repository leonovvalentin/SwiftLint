import SwiftSyntax

// \s+let\s+(?!\bthis\b)[a-zA-Z]+\s*\=\s*self\s*(else|\{|\,)
@SwiftSyntaxRule
struct StrongSelfAsThisRule: Rule {
    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "strong_self_as_this_new",
        name: "Strong Self As This Rule",
        description: "While unwrapping weak 'self' the name of strong 'self' should be 'this'",
        kind: .idiomatic,
        nonTriggeringExamples: [
            Example("let this = self")
        ],
        triggeringExamples: [
            Example(" let qwe=self else"),
            Example(" let qwe=self{"),
            Example(" let qwe=self,"),
            Example("   let qwe=self"),
            Example(" let   qwe=self"),
            Example(" let qwe   = self"),
            Example(" let qwe=   self"),
            Example(" let qwe=self   else"),
            Example(" let qwe=self   {"),
            Example(" let qwe=self   ,"),
            Example(" let self = self")
        ]
    )
}

private extension StrongSelfAsThisRule {
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {
        override func visitPost(_ node: DeclReferenceExprSyntax) {
            guard node.identifier.text == "self" else {
                return
            }
        }
    }
}
