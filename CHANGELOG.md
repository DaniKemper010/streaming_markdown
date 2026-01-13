## 0.0.4

* Enhanced README documentation to highlight instant rendering parameter (`shouldAnimate: false`)
* Added instant rendering note to Quick Start section

## 0.0.3

* Added documentation for `shouldAnimate` parameter in README
* The `shouldAnimate` parameter allows instant rendering of markdown without animation when set to `false`

## 0.0.2

* Version bump

## 0.0.1

* Initial release of streaming_markdown
* ChatGPT-style typing animation for markdown content
* Support for multiple animation modes: character, word, token, and custom chunk-based
* Real-time streaming support via Stream<String>
* Preset configurations matching popular AI assistants (ChatGPT, Claude, Grok, Perplexity, Gemini, Copilot)
* Extensible custom widget system with inline builders
* Built-in ButtonBuilder and ChipBuilder for interactive elements
* Custom syntax pattern support for flexible widget integration
* Full markdown support with GitHub Flavored Markdown
* Inline widgets work seamlessly within list items
* Performance optimizations with automatic throttling for large texts
* MarkdownTypingController for manual animation control
* Comprehensive API with customizable style sheets and syntax highlighting
