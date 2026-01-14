## 0.0.7

* Updated ChatGPT preset animation configuration with adjusted timing (wordDelay increased to 150ms)
* Code cleanup: Removed debug logging code from example app
* Code formatting improvements

## 0.0.6

* Performance enhancements: Added throttle multiplier to animation configuration for better performance with lengthy texts
* Large chunk stream support: Introduced `LargeChunkStreamExample` for handling large data streams with improved animation performance
* Debugging improvements: Added logging for debugging custom inline syntax processing and citation rendering
* Dependency updates: Updated `pubspec.lock` to reflect direct dependencies

## 0.0.5

* Added `onAnimationComplete` callback to `AnimatedMarkdown` widget
* The callback is invoked when the typing animation completes, receiving the final animated text as a parameter
* Works with both static markdown and streaming content

## 0.0.4

* Version bump

## 0.0.3

* Enhanced README documentation to highlight instant rendering parameter (`shouldAnimate: false`)
* Added instant rendering note to Quick Start section
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
