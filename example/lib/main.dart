import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:streaming_markdown/streaming_markdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Markdown Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const MarkdownDemoPage(),
    );
  }
}

class MarkdownDemoPage extends StatefulWidget {
  const MarkdownDemoPage({super.key});

  @override
  State<MarkdownDemoPage> createState() => _MarkdownDemoPageState();
}

class _MarkdownDemoPageState extends State<MarkdownDemoPage> {
  AnimationMode _selectedMode = AnimationMode.word;
  AnimationConfig? _selectedPreset;
  int _buttonPressCount = 0;
  final List<String> _pressedChips = [];
  int _selectedTab = 0;
  bool _shouldAnimate = true;

  final String _exampleMarkdown = '''
# Welcome to Animated Markdown! 🎉

This package provides **ChatGPT-style typing animation** for markdown content.

## Features

- ✨ Smooth typing animation
- 🎨 Multiple animation modes
- 🧩 Custom inline widgets
- 📝 Full markdown support

## Inline Widgets

You can use inline widgets like buttons and chips:

Click [[button:Click Me]] to see it in action!

Here are some tags: [[chip:Important]] [[chip:New]] [[chip:Featured]]

You can also show sources: [[source:Documentation]] [[source:GitHub]]

## Inline Widgets in Lists

Inline widgets work seamlessly within list items:

- First item with [[button:Action]] button
- Second item with [[chip:Tag]] chip
- Third item with both [[chip:First]] and [[button:Second]] widgets
  - Nested item with [[chip:Nested]] chip
  - Another nested with [[button:Nested Button]] button

## Ordered Lists

1. Item one with [[button:Click]] button
2. Item two with [[chip:Label]] chip
3. Item three with multiple widgets: [[chip:Tag1]] and [[chip:Tag2]]

## Code Example

Here's some code:

\`\`\`dart
AnimatedMarkdown(
  markdown: 'Hello [[button:World]]!',
  customBuilders: {
    'button': ButtonBuilder(),
  },
)
\`\`\`

## Math (Placeholder)

Math formula: [[math:E = mc²]]

## Source Attribution

Content from [[source:Research Paper]] and [[source:Official Docs]] can be cited inline.

## Citations

You can also use citation references like [1] and [2] with custom regex patterns!

This is a sentence with a citation [1] and another one [2]. Citations are clickable!

Enjoy using animated markdown! 🚀
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Markdown Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          _buildControls(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
              child: _selectedTab == 0
                  ? _buildStaticMarkdown()
                  : _selectedTab == 1
                  ? _buildStreamMarkdown()
                  : _buildLargeChunkStream(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(0, 'Static Markdown', Icons.text_fields)),
          Expanded(child: _buildTabButton(1, 'Stream Example', Icons.stream)),
          Expanded(child: _buildTabButton(2, 'Large Chunk Stream', Icons.data_usage)),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final bool isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticMarkdown() {
    return AnimatedMarkdown(
      markdown: _exampleMarkdown,
      shouldAnimate: _shouldAnimate,
      styleSheet: MarkdownStyleSheet().copyWith(p: TextStyle(color: Colors.purple)),
      config:
          _selectedPreset ??
          AnimationConfig(
            mode: _selectedMode,
            charDelay: const Duration(milliseconds: 10),
            wordDelay: const Duration(milliseconds: 50),
            tokenDelay: const Duration(milliseconds: 30),
            chunkSize: 1,
          ),
      customBuilders: {
        'button': ButtonBuilder(
          onPressed: (label) {
            setState(() {
              _buttonPressCount++;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Button "$label" pressed! (Count: $_buttonPressCount)'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        'chip': ChipBuilder(
          onPressed: (label) {
            setState(() {
              if (_pressedChips.contains(label)) {
                _pressedChips.remove(label);
              } else {
                _pressedChips.add(label);
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_pressedChips.contains(label) ? 'Chip "$label" selected!' : 'Chip "$label" deselected!'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        'math': MathBuilder(),
        'source': SourceBuilder(),
        'citation': CitationBuilder(
          onPressed: (citationNumber) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Citation [$citationNumber] clicked! Reference: Source $citationNumber'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      },
      customSyntaxPatterns: {'citation': r'\[(\d+)\]'},
      onAnimationComplete: (String finalText) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Animation completed!'), duration: Duration(seconds: 2)));
      },
    );
  }

  Widget _buildStreamMarkdown() {
    return StreamMarkdownExample(
      shouldAnimate: _shouldAnimate,

      config:
          _selectedPreset ??
          AnimationConfig(
            mode: _selectedMode,
            charDelay: const Duration(milliseconds: 10),
            wordDelay: const Duration(milliseconds: 50),
            tokenDelay: const Duration(milliseconds: 30),
          ),
      onButtonPressed: (label) {
        setState(() {
          _buttonPressCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Button "$label" pressed! (Count: $_buttonPressCount)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onChipPressed: (label) {
        setState(() {
          if (_pressedChips.contains(label)) {
            _pressedChips.remove(label);
          } else {
            _pressedChips.add(label);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_pressedChips.contains(label) ? 'Chip "$label" selected!' : 'Chip "$label" deselected!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _buildLargeChunkStream() {
    return LargeChunkStreamExample(
      shouldAnimate: _shouldAnimate,
      config:
          _selectedPreset ??
          AnimationConfig(
            mode: _selectedMode,
            charDelay: const Duration(milliseconds: 10),
            wordDelay: const Duration(milliseconds: 50),
            tokenDelay: const Duration(milliseconds: 30),
            chunkSize: 1,
          ),
      onButtonPressed: (label) {
        setState(() {
          _buttonPressCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Button "$label" pressed! (Count: $_buttonPressCount)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onChipPressed: (label) {
        setState(() {
          if (_pressedChips.contains(label)) {
            _pressedChips.remove(label);
          } else {
            _pressedChips.add(label);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_pressedChips.contains(label) ? 'Chip "$label" selected!' : 'Chip "$label" deselected!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Preset Config', style: Theme.of(context).textTheme.titleSmall)),
                Row(
                  children: [
                    Text('Animate', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(width: 8),
                    Switch(
                      value: _shouldAnimate,
                      onChanged: (value) {
                        setState(() {
                          _shouldAnimate = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPresetChip(null, 'Custom'),
                _buildPresetChip(AnimationConfig.chatGPT, 'ChatGPT'),
                _buildPresetChip(AnimationConfig.claude, 'Claude'),
                _buildPresetChip(AnimationConfig.grok, 'Grok'),
                _buildPresetChip(AnimationConfig.perplexity, 'Perplexity'),
                _buildPresetChip(AnimationConfig.gemini, 'Gemini'),
                _buildPresetChip(AnimationConfig.copilot, 'Copilot'),
              ],
            ),
            if (_selectedPreset == null) ...[
              const SizedBox(height: 16),
              Text('Animation Mode', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildModeChip(AnimationMode.character, 'Character'),
                  _buildModeChip(AnimationMode.word, 'Word'),
                  _buildModeChip(AnimationMode.token, 'Token'),
                  _buildModeChip(AnimationMode.custom, 'Custom'),
                ],
              ),
            ],
            if (_buttonPressCount > 0 || _pressedChips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Interactions', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_buttonPressCount > 0) Text('Button presses: $_buttonPressCount'),
              if (_pressedChips.isNotEmpty) Text('Selected chips: ${_pressedChips.join(", ")}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(AnimationMode mode, String label) {
    final bool isSelected = _selectedMode == mode;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMode = mode;
          });
        }
      },
    );
  }

  Widget _buildPresetChip(AnimationConfig? preset, String label) {
    final bool isSelected = _selectedPreset == preset;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPreset = preset;
            if (preset != null) {
              _selectedMode = preset.mode;
            }
          });
        }
      },
    );
  }
}

/// Builder for inline citation widgets: [1], [2], etc.
class CitationBuilder extends InlineBuilder {
  /// Callback when citation is pressed.
  final void Function(String citationNumber)? onPressed;

  /// Citation color.
  final Color? color;

  /// Creates a [CitationBuilder] with optional callback and color.
  CitationBuilder({this.onPressed, this.color});

  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String citationNumber = element.textContent;

    final Widget citationWidget = GestureDetector(
      onTap: onPressed != null ? () => onPressed!(citationNumber) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: (color ?? Colors.blue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color ?? Colors.blue, width: 1),
        ),
        child: Text(
          '[$citationNumber]',
          style: (style ?? const TextStyle()).copyWith(
            color: color ?? Colors.blue,
            fontSize: (style?.fontSize ?? 14) * 0.85,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    return Text.rich(
      TextSpan(
        children: [WidgetSpan(alignment: PlaceholderAlignment.middle, child: citationWidget)],
      ),
      style: style,
    );
  }
}

/// Builder for inline source widgets: [[source:Source Name]]
class SourceBuilder extends InlineBuilder {
  /// Source color.
  final Color? color;

  /// Creates a [SourceBuilder] with optional color.
  SourceBuilder({this.color});

  @override
  Widget buildInline(md.Element element, TextStyle? style) {
    final String source = element.textContent;

    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color ?? Colors.blue, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.source, size: 14, color: color ?? Colors.blue),
                const SizedBox(width: 4),
                Text(
                  source,
                  style: style?.copyWith(color: color ?? Colors.blue, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StreamMarkdownExample extends StatefulWidget {
  final AnimationConfig config;
  final bool shouldAnimate;
  final void Function(String) onButtonPressed;
  final void Function(String) onChipPressed;

  const StreamMarkdownExample({
    super.key,
    required this.config,
    this.shouldAnimate = true,
    required this.onButtonPressed,
    required this.onChipPressed,
  });

  @override
  State<StreamMarkdownExample> createState() => _StreamMarkdownExampleState();
}

class _StreamMarkdownExampleState extends State<StreamMarkdownExample> {
  StreamController<String>? _streamController;
  int _streamKey = 0;
  Stream<String>? _currentStream;

  final String _streamExampleContent = '''
# Streaming Markdown Example 📡

This demonstrates how **AnimatedMarkdown** handles streaming content in real-time.

## How It Works

The content below is being streamed chunk by chunk, simulating a real-world scenario like:

- API responses
- WebSocket messages
- Server-sent events
- Large file processing

## Features Demonstrated

- ✨ **Real-time streaming**: Content appears as it arrives
- 🔄 **Continuous animation**: Animation continues seamlessly as new chunks arrive
- 📦 **Large chunk handling**: Handles both small and large data chunks
- ⚡ **Non-blocking**: UI remains responsive during streaming

## Example Content

This is the first chunk of content. Notice how the animation continues smoothly.

Here comes more content! The animation doesn't stop or restart.

### Lists Work Too

- First streaming item
- Second streaming item
- Third streaming item with [[chip:Streaming]] support

### Code Blocks

\`\`\`dart
// This code block is streamed in chunks
Stream<String> markdownStream = getMarkdownStream();
AnimatedMarkdown(
  stream: markdownStream,
  config: AnimationConfig.chatGPT,
)
\`\`\`

## Interactive Elements

You can even stream interactive elements: [[button:Streamed Button]]

And chips work too: [[chip:Streamed]] [[chip:Content]]

Sources work in streams too: [[source:API Response]] [[source:WebSocket]]

Citations also work in streams: This is streamed content with citation [1] and [2].

## Final Thoughts

The stream continues to work even with large amounts of content. The animation adapts and continues smoothly, making it perfect for real-time applications!

🎉 **Streaming complete!**
''';

  Stream<String> _createMarkdownStream() {
    _streamController?.close();
    _streamController = StreamController<String>.broadcast();
    final List<String> chunks = _splitIntoChunks(_streamExampleContent);
    _streamChunks(chunks, 0);
    return _streamController!.stream;
  }

  void _streamChunks(List<String> chunks, int index) {
    if (index >= chunks.length) {
      _streamController?.close();
      return;
    }
    Future.delayed(Duration(milliseconds: 100 + (index % 5) * 50), () {
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(chunks[index]);
        _streamChunks(chunks, index + 1);
      }
    });
  }

  List<String> _splitIntoChunks(String text) {
    final List<String> chunks = [];
    final int chunkSize = 50;
    for (int i = 0; i < text.length; i += chunkSize) {
      final int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }

  void _restartStream() {
    setState(() {
      _streamController?.close();
      _streamController = null;
      _currentStream = null;
      _streamKey++;
    });
  }

  Stream<String> _getOrCreateStream() {
    _currentStream ??= _createMarkdownStream();
    return _currentStream!;
  }

  @override
  void dispose() {
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _restartStream,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart Stream'),
          ),
        ),
        AnimatedMarkdown(
          key: ValueKey<int>(_streamKey),
          stream: _getOrCreateStream(),
          styleSheet: MarkdownStyleSheet().copyWith(p: TextStyle(color: Colors.red)),
          shouldAnimate: widget.shouldAnimate,
          config: widget.config,
          customBuilders: {
            'button': ButtonBuilder(onPressed: widget.onButtonPressed),
            'chip': ChipBuilder(onPressed: widget.onChipPressed),
            'math': MathBuilder(),
            'source': SourceBuilder(),
            'citation': CitationBuilder(
              onPressed: (citationNumber) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Citation [$citationNumber] clicked! Reference: Source $citationNumber'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          },
          customSyntaxPatterns: {'citation': r'\[(\d+)\]'},
          onAnimationComplete: (String finalText) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stream animation completed!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
      ],
    );
  }
}

class LargeChunkStreamExample extends StatefulWidget {
  final AnimationConfig config;
  final bool shouldAnimate;
  final void Function(String) onButtonPressed;
  final void Function(String) onChipPressed;

  const LargeChunkStreamExample({
    super.key,
    required this.config,
    this.shouldAnimate = true,
    required this.onButtonPressed,
    required this.onChipPressed,
  });

  @override
  State<LargeChunkStreamExample> createState() => _LargeChunkStreamExampleState();
}

class _LargeChunkStreamExampleState extends State<LargeChunkStreamExample> {
  StreamController<String>? _streamController;
  int _streamKey = 0;
  Stream<String>? _currentStream;

  final String _streamExampleContent = '''
# Streaming Markdown Example 📡

This demonstrates how **AnimatedMarkdown** handles streaming content in real-time.

## How It Works

The content below is being streamed chunk by chunk, simulating a real-world scenario like:

- API responses
- WebSocket messages
- Server-sent events
- Large file processing

## Features Demonstrated

- ✨ **Real-time streaming**: Content appears as it arrives
- 🔄 **Continuous animation**: Animation continues seamlessly as new chunks arrive
- 📦 **Large chunk handling**: Handles both small and large data chunks
- ⚡ **Non-blocking**: UI remains responsive during streaming

## Example Content

This is the first chunk of content. Notice how the animation continues smoothly.

Here comes more content! The animation doesn't stop or restart.

### Lists Work Too

- First streaming item
- Second streaming item
- Third streaming item with [[chip:Streaming]] support

### Code Blocks

\`\`\`dart
// This code block is streamed in chunks
Stream<String> markdownStream = getMarkdownStream();
AnimatedMarkdown(
  stream: markdownStream,
  config: AnimationConfig.chatGPT,
)
\`\`\`

## Interactive Elements

You can even stream interactive elements: [[button:Streamed Button]]

And chips work too: [[chip:Streamed]] [[chip:Content]]

Sources work in streams too: [[source:API Response]] [[source:WebSocket]]

Citations also work in streams: This is streamed content with citation [1] and [2].

## Final Thoughts

The stream continues to work even with large amounts of content. The animation adapts and continues smoothly, making it perfect for real-time applications!

🎉 **Streaming complete!**
''';

  Stream<String> _createMarkdownStream() {
    _streamController?.close();
    _streamController = StreamController<String>.broadcast();
    final List<String> chunks = _splitIntoLargeChunks(_streamExampleContent);
    _streamLargeChunks(chunks, 0);
    return _streamController!.stream;
  }

  void _streamLargeChunks(List<String> chunks, int index) {
    if (index >= chunks.length) {
      _streamController?.close();
      return;
    }
    final Duration delay = index == 0 ? Duration.zero : const Duration(seconds: 3);
    Future.delayed(delay, () {
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(chunks[index]);
        _streamLargeChunks(chunks, index + 1);
      }
    });
  }

  List<String> _splitIntoLargeChunks(String text) {
    final int splitPoint = (text.length * 0.6).round();
    int bestSplitPoint = splitPoint;
    for (int i = splitPoint - 50; i < splitPoint + 50 && i < text.length; i++) {
      if (i > 0 && text[i] == '\n' && (i == text.length - 1 || text[i + 1] == '\n')) {
        bestSplitPoint = i + 1;
        break;
      }
    }
    return [text.substring(0, bestSplitPoint), text.substring(bestSplitPoint)];
  }

  void _restartStream() {
    setState(() {
      _streamController?.close();
      _streamController = null;
      _currentStream = null;
      _streamKey++;
    });
  }

  Stream<String> _getOrCreateStream() {
    _currentStream ??= _createMarkdownStream();
    return _currentStream!;
  }

  @override
  void dispose() {
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _restartStream,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart Stream'),
          ),
        ),
        AnimatedMarkdown(
          key: ValueKey<int>(_streamKey),
          stream: _getOrCreateStream(),
          styleSheet: MarkdownStyleSheet().copyWith(p: TextStyle(color: Colors.red)),
          shouldAnimate: widget.shouldAnimate,
          config: widget.config,
          customBuilders: {
            'button': ButtonBuilder(onPressed: widget.onButtonPressed),
            'chip': ChipBuilder(onPressed: widget.onChipPressed),
            'math': MathBuilder(),
            'source': SourceBuilder(),
            'citation': CitationBuilder(
              onPressed: (citationNumber) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Citation [$citationNumber] clicked! Reference: Source $citationNumber'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          },
          customSyntaxPatterns: {'citation': r'\[(\d+)\]'},
          onAnimationComplete: (String finalText) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Large chunk stream animation completed!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
