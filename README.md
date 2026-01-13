# Animated Markdown Renderer

A production-ready Flutter package for animated markdown rendering with ChatGPT-style typing animation, supporting customizable animation speed, chunk size, multiple animation modes, and an extensible custom widget system.

## Features

- ✨ **ChatGPT-style typing animation** - Smooth, configurable typing effects
- 🎨 **Multiple animation modes** - Character, word, token, or custom chunk-based
- 🧩 **Extensible custom widgets** - Easy to add custom inline widgets
- 📝 **Full Markdown support** - All standard markdown features
- 🎯 **Inline widgets in lists** - Custom widgets work seamlessly within list items
- ⚡ **Performance optimized** - Automatic throttling for large texts
- 🎛️ **Fully configurable** - Control speed, chunk size, and more

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  streaming_markdown:
    path: ../streaming_markdown  # or use pub.dev version when published
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

## Usage

### Basic Usage

```dart
AnimatedMarkdown(
  markdown: '# Hello\nThis is animated markdown!',
)
```

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

### Inline Builder

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

### Custom Syntax

Create a custom syntax parser:

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

Then register it in your `MarkdownRenderer`:

```dart
MarkdownRenderer(
  data: markdown,
  customBuilders: {
    'mywidget': MyInlineBuilder(),
  },
)
```

## API Reference

### `AnimatedMarkdown`

Main widget for animated markdown rendering.

**Properties:**
- `markdown` (String, required) - Markdown text to animate
- `config` (AnimationConfig?) - Animation configuration
- `customBuilders` (Map<String, CustomMarkdownBuilder>?) - Custom widget builders
- `selectable` (bool) - Whether text is selectable (default: true)
- `styleSheet` (MarkdownStyleSheet?) - Custom markdown style sheet
- `autoStart` (bool) - Whether to auto-start animation (default: true)

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

Controller for managing typing animation.

**Methods:**
- `start()` - Start the animation
- `pause()` - Pause the animation
- `resume()` - Resume the animation
- `stop()` - Stop the animation
- `reset()` - Reset to beginning
- `jumpToEnd()` - Jump to end immediately

**Properties:**
- `text` (String) - Current displayed text
- `isRunning` (bool) - Whether animation is running
- `isPaused` (bool) - Whether animation is paused
- `progress` (double) - Progress (0.0 to 1.0)
- `isComplete` (bool) - Whether animation is complete

### Built-in Builders

- `ButtonBuilder` - Inline button widget
- `ChipBuilder` - Inline chip/tag widget
- `MathBuilder` - Math/LaTeX widget (placeholder)

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
