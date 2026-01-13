# Animated Markdown Renderer

A production-ready Flutter package for animated markdown rendering with ChatGPT-style typing animation, supporting customizable animation speed, chunk size, multiple animation modes, and an extensible custom widget system.

## Features

- ✨ **ChatGPT-style typing animation** - Smooth, configurable typing effects
- 📡 **Real-time streaming support** - Stream markdown content as it arrives
- 🎨 **Multiple animation modes** - Character, word, token, or custom chunk-based
- 🎯 **Preset configurations** - Pre-configured styles matching popular AI assistants (ChatGPT, Claude, Grok, etc.)
- 🧩 **Extensible custom widgets** - Easy to add custom inline widgets with custom syntax patterns
- 📝 **Full Markdown support** - All standard markdown features
- 🎯 **Inline widgets in lists** - Custom widgets work seamlessly within list items
- ⚡ **Performance optimized** - Automatic throttling for large texts
- 🎛️ **Fully configurable** - Control speed, chunk size, and more

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  streaming_markdown: ^0.0.4
  # For local development, use: streaming_markdown: { path: ../streaming_markdown }
```

## Quick Start

```dart
import 'package:streaming_markdown/streaming_markdown.dart';

AnimatedMarkdown(
  markdown: '''
# Hello World
This is **animated** markdown with [[button:Click Me]] inline!

- List item with [[chip:Tag]] inline widget
- Another item with [[button:Action]] button
  - Nested list with [[chip:Nested]] chip
''',
  config: AnimationConfig(
    mode: AnimationMode.word,
    wordDelay: Duration(milliseconds: 50),
    chunkSize: 5,
  ),
  customBuilders: {
    'button': ButtonBuilder(),
    'chip': ChipBuilder(),
  },
)
```

**Instant Rendering:** Set `shouldAnimate: false` to render markdown instantly without animation.

## Usage

### Basic Usage

```dart
AnimatedMarkdown(
  markdown: '# Hello\nThis is animated markdown!',
)
```

### Instant Rendering

To render markdown instantly without animation, set `shouldAnimate: false`:

```dart
AnimatedMarkdown(
  markdown: '# Hello\nThis is rendered instantly!',
  shouldAnimate: false,
)
```

This is useful when you want to display content immediately or toggle between animated and instant rendering.

### Custom Animation Configuration

```dart
AnimatedMarkdown(
  markdown: 'Your markdown here',
  config: AnimationConfig(
    mode: AnimationMode.character,  // or .word, .token, .custom
    charDelay: Duration(milliseconds: 15),
    wordDelay: Duration(milliseconds: 50),
    tokenDelay: Duration(milliseconds: 30),
    chunkSize: 1,  // For batch rendering
    throttleThreshold: 1000,  // Performance optimization
  ),
)
```

### Streaming Content

`AnimatedMarkdown` supports real-time streaming of markdown content via a `Stream<String>`. This is perfect for LLM responses, API streams, or any real-time content delivery. The widget automatically animates content as it arrives from the stream.

**Basic Streaming:**
```dart
Stream<String> markdownStream = getMarkdownStream();

AnimatedMarkdown(
  stream: markdownStream,
  config: AnimationConfig(
    mode: AnimationMode.token,  // Token mode is optimal for streaming
    tokenDelay: Duration(milliseconds: 30),
  ),
)
```

**With Custom Builders:**
```dart
AnimatedMarkdown(
  stream: markdownStream,
  config: AnimationConfig.chatGPT,
  customBuilders: {
    'button': ButtonBuilder(),
    'chip': ChipBuilder(),
  },
)
```

**Creating a Stream:**
```dart
Stream<String> createMarkdownStream() {
  final controller = StreamController<String>();
  
  // Simulate streaming chunks
  Future.microtask(() async {
    final chunks = ['# Hello\n', 'This is **streamed** ', 'content!\n'];
    for (final chunk in chunks) {
      await Future.delayed(Duration(milliseconds: 100));
      controller.add(chunk);
    }
    await controller.close();
  });
  
  return controller.stream;
}
```

The controller automatically handles stream completion and continues animating until all content is displayed. See the `example/` directory for a complete streaming example.

### Animation Complete Callback

You can be notified when the typing animation completes using the `onAnimationComplete` callback. This is useful for triggering actions after the animation finishes, such as showing a completion indicator or enabling user interactions.

**With Static Markdown:**
```dart
AnimatedMarkdown(
  markdown: '# Hello\nThis is animated markdown!',
  onAnimationComplete: (String finalText) {
    print('Animation completed! Final text length: ${finalText.length}');
    // Perform actions after animation completes
  },
)
```

**With Streaming Content:**
```dart
AnimatedMarkdown(
  stream: markdownStream,
  onAnimationComplete: (String finalText) {
    print('Stream animation completed!');
    print('Total content: ${finalText.length} characters');
    // Handle completion of streamed content
  },
)
```

**With Instant Rendering:**
When `shouldAnimate: false`, the callback is invoked immediately after the content is rendered:
```dart
AnimatedMarkdown(
  markdown: '# Instant content',
  shouldAnimate: false,
  onAnimationComplete: (String finalText) {
    // Called immediately after rendering
    print('Content rendered: $finalText');
  },
)
```

### Animation Modes

#### Character Mode
Smooth, character-by-character animation:
```dart
AnimationConfig(
  mode: AnimationMode.character,
  charDelay: Duration(milliseconds: 15),
)
```

#### Word Mode
Faster, word-by-word animation (default):
```dart
AnimationConfig(
  mode: AnimationMode.word,
  wordDelay: Duration(milliseconds: 50),
)
```

#### Token Mode
Optimal for LLM streaming:
```dart
AnimationConfig(
  mode: AnimationMode.token,
  tokenDelay: Duration(milliseconds: 30),
)
```

#### Custom Mode
Configurable chunk-based rendering:
```dart
AnimationConfig(
  mode: AnimationMode.custom,
  chunkSize: 10,  // Characters per chunk
  charDelay: Duration(milliseconds: 20),
)
```

### Preset Configurations

`AnimationConfig` provides preset configurations that match popular AI assistant typing styles. These presets are optimized for different use cases:

**ChatGPT Style:**
Character-based animation with smooth unit animations and slide effects:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.chatGPT,
)
```

**Claude Style:**
Word-based animation with faster timing, optimized for quick responses:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.claude,
)
```

**Grok Style:**
Fast token-based animation optimized for quick responses and real-time interactions:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.grok,
)
```

**Perplexity Style:**
Fast word-based animation optimized for quick information delivery:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.perplexity,
)
```

**Gemini Style:**
Moderate word-based animation with slightly slower pacing:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.gemini,
)
```

**Copilot Style:**
Very fast token-based animation optimized for code generation and technical content:
```dart
AnimatedMarkdown(
  markdown: 'Your content',
  config: AnimationConfig.copilot,
)
```

**All Available Presets:**
- `AnimationConfig.chatGPT` - Character mode with smooth animations
- `AnimationConfig.claude` - Word mode with fast timing
- `AnimationConfig.grok` - Token mode for quick responses
- `AnimationConfig.perplexity` - Word mode for information delivery
- `AnimationConfig.gemini` - Word mode with moderate pacing
- `AnimationConfig.copilot` - Token mode for code generation

### Custom Widgets

#### Inline Widgets

Inline widgets work within text and list items:

**Buttons:**
```dart
AnimatedMarkdown(
  markdown: 'Click [[button:Click Me]] here',
  customBuilders: {
    'button': ButtonBuilder(
      onPressed: (label) => print('Button pressed: $label'),
    ),
  },
)
```

**Chips:**
```dart
AnimatedMarkdown(
  markdown: 'Tag: [[chip:Important]]',
  customBuilders: {
    'chip': ChipBuilder(
      onPressed: (label) => print('Chip pressed: $label'),
      color: Colors.blue,
    ),
  },
)
```

**In List Items:**
```dart
AnimatedMarkdown(
  markdown: '''
- Item with [[button:Action]] button
- Another with [[chip:Tag]] chip
  - Nested with [[button:Nested]] button
''',
  customBuilders: {
    'button': ButtonBuilder(),
    'chip': ChipBuilder(),
  },
)
```

### Manual Control

Control animation by setting `autoStart: false` and using a `MarkdownTypingController` directly:

```dart
final controller = MarkdownTypingController(
  fullText: 'Your text',
  config: AnimationConfig(mode: AnimationMode.word),
);

// Start animation
controller.start();

// Control animation
controller.pause();
controller.resume();
controller.stop();
controller.reset();
controller.jumpToEnd();
```

## Creating Custom Builders

The package provides a flexible builder system for creating custom markdown widgets. There are two base classes you can extend:

### CustomMarkdownBuilder

The base class for all custom builders. Use this when you need full control over widget building:

```dart
class MyCustomBuilder extends CustomMarkdownBuilder {
  @override
  Widget? buildWidget(md.Element element, TextStyle? style) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(element.textContent),
    );
  }
}
```

### InlineBuilder

Extend `InlineBuilder` for inline widgets that appear within text and list items. This is the recommended approach for most custom widgets:

```dart
class MyInlineBuilder extends InlineBuilder {
  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Text(element.textContent),
    );
  }
}
```

### Custom Syntax Patterns

By default, custom builders use the pattern `[[key:content]]`. You can customize this pattern using the `customSyntaxPatterns` parameter:

```dart
AnimatedMarkdown(
  markdown: 'Citation [1] and [2] in text',
  customBuilders: {
    'citation': CitationBuilder(),
  },
  customSyntaxPatterns: {
    'citation': r'\[(\d+)\]',  // Custom regex pattern
  },
)
```

The custom pattern should include at least one capture group to extract the content. The first capture group will be used as the content.

**Example: Citation Builder with Custom Pattern**

```dart
class CitationBuilder extends InlineBuilder {
  final Function(String)? onPressed;
  
  CitationBuilder({this.onPressed});
  
  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    return GestureDetector(
      onTap: () => onPressed?.call(element.textContent),
      child: Text(
        '[${element.textContent}]',
        style: style?.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// Usage with custom pattern
AnimatedMarkdown(
  markdown: 'This is content with citation [1] and [2].',
  customBuilders: {
    'citation': CitationBuilder(
      onPressed: (number) => print('Citation $number clicked'),
    ),
  },
  customSyntaxPatterns: {
    'citation': r'\[(\d+)\]',  // Matches [1], [2], etc.
  },
)
```

### Custom Syntax (Advanced)

For more complex syntax requirements, you can create a custom syntax parser:

```dart
class MyInlineSyntax extends CustomInlineSyntax {
  MyInlineSyntax() : super(RegExp(r'\[\[mywidget:(.*?)\]\]'));

  @override
  md.Node parseMatch(md.InlineParser parser, Match match) {
    final String content = match.group(1)?.trim() ?? '';
    return md.Element.text('mywidget', content);
  }
}
```

However, for most use cases, using `customSyntaxPatterns` with `InlineBuilder` is simpler and recommended.

### Registering Builders

Register your custom builders in `AnimatedMarkdown` or `MarkdownRenderer`:

```dart
AnimatedMarkdown(
  markdown: 'Content with [[mywidget:Custom Content]]',
  customBuilders: {
    'mywidget': MyInlineBuilder(),
  },
  customSyntaxPatterns: {
    'mywidget': r'\[\[mywidget:(.*?)\]\]',  // Optional custom pattern
  },
)
```

## API Reference

### `AnimatedMarkdown`

Main widget for animated markdown rendering.

**Properties:**
- `markdown` (String?) - Markdown text to animate (either `markdown` or `stream` must be provided)
- `stream` (Stream<String>?) - Stream of markdown text chunks to animate in real-time (either `markdown` or `stream` must be provided)
- `config` (AnimationConfig?) - Animation configuration
- `customBuilders` (Map<String, CustomMarkdownBuilder>?) - Custom widget builders
- `customSyntaxPatterns` (Map<String, String>?) - Custom regex patterns for builders. Maps builder keys to their regex patterns. If a builder key has a custom pattern, it will be used instead of the default `[[key:content]]` pattern
- `selectable` (bool) - Whether text is selectable (default: true)
- `styleSheet` (MarkdownStyleSheet?) - Custom markdown style sheet
- `extensionSet` (ExtensionSet?) - Custom extension set for markdown parsing. If not provided, uses GitHub Flavored Markdown as default
- `syntaxHighlighter` (SyntaxHighlighter?) - Syntax highlighter for code blocks
- `onTapLink` (MarkdownTapLinkCallback?) - Callback for handling link taps
- `shrinkWrap` (bool) - Whether the widget should take the minimum height that wraps its content (default: true)
- `softLineBreak` (bool) - Whether to handle soft line breaks (default: false)
- `autoStart` (bool) - Whether to auto-start animation (default: true)
- `shouldAnimate` (bool) - Whether to animate the markdown text. When `false`, the markdown is rendered instantly without animation (default: true)
- `onAnimationComplete` (void Function(String)?) - Callback invoked when the typing animation completes. Receives the final animated text as a parameter. Works with both static markdown and streaming content

### `AnimationConfig`

Configuration for typing animation.

**Properties:**
- `mode` (AnimationMode) - Animation mode (default: AnimationMode.word)
- `charDelay` (Duration) - Delay between characters (default: 15ms)
- `wordDelay` (Duration) - Delay between words (default: 50ms)
- `tokenDelay` (Duration) - Delay between tokens (default: 30ms)
- `chunkSize` (int) - Chunk size for batch rendering (default: 1)
- `throttleThreshold` (int) - Threshold for performance throttling (default: 1000)

### `MarkdownTypingController`

Controller for managing typing animation. Supports both static text and streaming content.

**Constructor:**
- `MarkdownTypingController({String? fullText, Stream<String>? stream, AnimationConfig? config})` - Creates a controller with either static text (`fullText`) or a stream (`stream`). Exactly one must be provided.

**Methods:**
- `start()` - Start the animation
- `pause()` - Pause the animation
- `resume()` - Resume the animation
- `stop()` - Stop the animation
- `reset()` - Reset to beginning
- `jumpToEnd()` - Jump to end immediately

**Properties:**
- `fullText` (String) - Full text to animate (accumulated text from stream or initial text)
- `text` (String) - Current displayed text
- `isRunning` (bool) - Whether animation is running
- `isPaused` (bool) - Whether animation is paused
- `progress` (double) - Progress (0.0 to 1.0)
- `isComplete` (bool) - Whether animation is complete (for streams, checks if stream is completed)

### `MarkdownRenderer`

Renders markdown with custom builders and syntaxes.

**Properties:**
- `data` (String, required) - Markdown text to render
- `customBuilders` (Map<String, CustomMarkdownBuilder>?) - Custom widget builders
- `customSyntaxPatterns` (Map<String, String>?) - Custom regex patterns for builders. Maps builder keys to their regex patterns. If a builder key has a custom pattern, it will be used instead of the default `[[key:content]]` pattern
- `selectable` (bool) - Whether text is selectable (default: true)
- `styleSheet` (MarkdownStyleSheet?) - Custom markdown style sheet
- `animationConfig` (AnimationConfig?) - Animation configuration for unit-level animations
- `extensionSet` (ExtensionSet?) - Custom extension set for markdown parsing. If not provided, uses GitHub Flavored Markdown as default
- `syntaxHighlighter` (SyntaxHighlighter?) - Syntax highlighter for code blocks
- `onTapLink` (MarkdownTapLinkCallback?) - Callback for handling link taps
- `shrinkWrap` (bool) - Whether the widget should take the minimum height that wraps its content (default: true)
- `softLineBreak` (bool) - Whether to handle soft line breaks (default: false)

### Built-in Builders

- `ButtonBuilder` - Inline button widget
- `ChipBuilder` - Inline chip/tag widget
- `MathBuilder` - Math/LaTeX widget (placeholder)

### Builder Base Classes

- `CustomMarkdownBuilder` - Base class for all custom markdown builders
- `InlineBuilder` - Base class for inline widgets that appear within text and list items

## Performance Tips

1. **Use word mode** for faster animation on large texts
2. **Increase chunk size** for batch rendering
3. **Set throttleThreshold** to enable automatic throttling for very long texts
4. **Disable autoStart** and control manually for better performance

## Examples

See the `example/` directory for complete examples.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
