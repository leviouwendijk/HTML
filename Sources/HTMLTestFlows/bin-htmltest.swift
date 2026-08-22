import HTML
import TestFlows

@main
enum HTMLTestFlowMain {
    static func main() async {
        await TestFlowCLI.run(
            suite:
                HTMLFlowSuite.self
        )
    }
}

enum HTMLFlowSuite:
    TestFlowRegistry
{
    static let title =
        "HTML semantic flows"

    static let flows:
        [TestFlow] =
    [
        serializationPolicy,
        semanticContentParity,
        plainTextCollection,
    ]

    static let serializationPolicy =
        TestFlow(
            "serialization-policy",
            title:
                "HTML render options describe textual representation only",
            tags: [
                "html",
                "rendering",
                "serialization",
            ]
        ) {
            Step(
                "pretty preset controls formatting"
            ) {
                let options =
                    HTMLRenderOptions
                        .Defaults
                        .pretty()

                try Expect.equal(
                    options.indentation,
                    true,
                    "serialization.pretty.indentation"
                )

                try Expect.equal(
                    options.newlineSeparated,
                    true,
                    "serialization.pretty.newlines"
                )

                try Expect.equal(
                    options.indentStep,
                    4,
                    "serialization.pretty.indent-step"
                )
            }

            Step(
                "minified preset controls formatting"
            ) {
                let options =
                    HTMLRenderOptions
                        .Defaults
                        .minified()

                try Expect.equal(
                    options.indentation,
                    false,
                    "serialization.minified.indentation"
                )

                try Expect.equal(
                    options.newlineSeparated,
                    false,
                    "serialization.minified.newlines"
                )

                try Expect.equal(
                    options.indentStep,
                    0,
                    "serialization.minified.indent-step"
                )
            }
        }

    static let semanticContentParity =
        TestFlow(
            "semantic-content-parity",
            title:
                "Serializer formatting choices do not decide whether semantic content exists",
            tags: [
                "html",
                "serialization",
                "parity",
            ]
        ) {
            Step(
                "pretty and minified preserve the same document content"
            ) {
                let document =
                    HTMLDocument(
                        attributes:
                            .empty,
                        body: [
                            HTMLText(
                                "semantic-content"
                            ),
                        ]
                    )

                let pretty =
                    document
                        .render(
                            default:
                                .pretty
                        )

                let minified =
                    document
                        .render(
                            default:
                                .minified
                        )

                try Expect.equal(
                    pretty.contains(
                        "semantic-content"
                    ),
                    true,
                    "serialization.pretty-content"
                )

                try Expect.equal(
                    minified.contains(
                        "semantic-content"
                    ),
                    true,
                    "serialization.minified-content"
                )

                try Expect.equal(
                    pretty
                        .replacingOccurrences(
                            of:
                                "\n",
                            with:
                                ""
                        )
                        .replacingOccurrences(
                            of:
                                "    ",
                            with:
                                ""
                        )
                        .contains(
                            "semantic-content"
                        ),
                    minified.contains(
                        "semantic-content"
                    ),
                    "serialization.content-existence-parity"
                )
            }
        }

    static let plainTextCollection =
        TestFlow(
            "plain-text-collection",
            title:
                "HTML-local analysis consumes the supplied tree without environment projection",
            tags: [
                "html",
                "plaintext",
                "semantic",
            ]
        ) {
            Step(
                "collect supplied semantic text"
            ) {
                let nodes:
                    HTMLFragment =
                [
                    HTMLText(
                        "alpha"
                    ),

                    HTMLText(
                        " beta"
                    ),
                ]

                try Expect.equal(
                    nodes.plaintext(),
                    "alpha beta",
                    "plaintext.content"
                )
            }
        }
}
