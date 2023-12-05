import SwiftSyntax

// Original rule: \s+let\s+(?!\bthis\b)[a-zA-Z]+\s*\=\s*self\s*(else|\{|\,)

@SwiftSyntaxRule
struct StrongSelfAsThisRule: Rule {

    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "strong_self_as_this_new",
        name: "Strong Self As This Rule",
        description: "While unwrapping weak 'self' the name of strong 'self' should be 'this'",
        kind: .idiomatic,
        nonTriggeringExamples: [
            Example("if let a = b, let this = self"),
            Example("guard let a = b, let this = self"),
        ],
        triggeringExamples: [
            Example("if let a = b, let ↓c = self"),
            Example("guard let a = b, let ↓c = self"),
            Example("let ↓qwe = self")
        ]
    )

}

private extension StrongSelfAsThisRule {

    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {

        // MARK: - Internal Methods

        override func visitPost(_ node: IfExprSyntax) {
            checkIfGuard(conditions: node.conditions)
        }

        override func visitPost(_ node: GuardStmtSyntax) {
            checkIfGuard(conditions: node.conditions)
        }

        override func visitPost(_ node: VariableDeclSyntax) {
            for binding in node.bindings {

                guard let initializer = binding.initializer,
                      checkEqualSelf(initializer: initializer) else {

                    continue
                }

                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                      !checkThis(pattern: pattern) else {

                    continue
                }

                violations.append(pattern.positionAfterSkippingLeadingTrivia)
            }
        }

        // MARK: - Private Methods

        private func checkIfGuard(conditions: ConditionElementListSyntax) {
            for condition in conditions {

                guard let binding = condition.condition.as(OptionalBindingConditionSyntax.self),
                      let initializer = binding.initializer,
                      checkEqualSelf(initializer: initializer) else {

                    continue
                }

                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                      !checkThis(pattern: pattern) else {

                    continue
                }

                violations.append(pattern.positionAfterSkippingLeadingTrivia)
            }
        }

        private func checkEqualSelf(initializer: InitializerClauseSyntax) -> Bool {
            if initializer.equal.tokenKind == .equal,
               let value = initializer.value.as(DeclReferenceExprSyntax.self),
               value.baseName.tokenKind == .keyword(.self) {

                return true
            }

            return false
        }

        private func checkThis(pattern: IdentifierPatternSyntax) -> Bool {
            pattern.identifier.tokenKind == .identifier("this")
        }

    }
}
