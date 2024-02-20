import SwiftSyntax
import SourceKittenFramework

struct SingleWhitespaceRule: CorrectableRule {

    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "single_whitespace",
        name: "Single Whitespace Rule",
        description: "If it is not start of line, no more then one whitespace allowed",
        kind: .style,
        nonTriggeringExamples: [
//            Example("  let a = b"),
//            Example("   case a:")
        ],
        triggeringExamples: [
            Example("  let a↓  = b"),
            Example("   case a↓  :")
//            Example("{  a   in"),
//            Example("switch   a  {")
        ]
    )

}

extension SingleWhitespaceRule {

    func validate(file: SwiftLintFile) -> [StyleViolation] {
        var violations: [StyleViolation] = []

        for line in file.lines {
            let counters = findSeveralWhitespacesConsecutive(line: line)
            for counter in counters {
                let location = Location(file: file.path, line: line.index, character: counter.firstWhitespaceIndex)
                let violation = StyleViolation(ruleDescription: Self.description, severity: configuration.severity, location: location)
                violations.append(violation)
            }
        }

        return violations
    }

    func correct(file: SwiftLintFile) -> [Correction] {
        return []
    }

    // MARK: - Private Methods

    private func findSeveralWhitespacesConsecutive(line: Line) -> [(firstWhitespaceIndex: Int, numberOfWhitespaces: Int)] {
        var result: [(firstWhitespaceIndex: Int, numberOfWhitespaces: Int)] = []
        var firstNotWhitespaceIndex: Int? = nil
        var counter: (firstWhitespaceIndex: Int, numberOfWhitespaces: Int) = (0, 0)

        for (index, character) in line.content.enumerated() {
            if !character.isWhitespace && firstNotWhitespaceIndex == nil {
                firstNotWhitespaceIndex = index
            }

            if firstNotWhitespaceIndex == nil {
                continue
            }

            guard character.isWhitespace else {
                continue
            }

            if counter.firstWhitespaceIndex + counter.numberOfWhitespaces == index {
                counter = (counter.firstWhitespaceIndex, counter.numberOfWhitespaces + 1)
            }
            else {
                if counter.numberOfWhitespaces > 1 {
                    result.append(counter)
                }

                counter = (index, 1)
            }
        }

        if counter.numberOfWhitespaces > 1 {
            result.append(counter)
        }

        return result
    }

}
