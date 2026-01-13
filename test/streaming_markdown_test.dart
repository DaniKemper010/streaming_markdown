import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaming_markdown/streaming_markdown.dart';

void main() {
  group('AnimationConfig', () {
    test('creates with default values', () {
      const AnimationConfig config = AnimationConfig();
      expect(config.mode, AnimationMode.word);
      expect(config.charDelay, const Duration(milliseconds: 15));
      expect(config.wordDelay, const Duration(milliseconds: 50));
      expect(config.chunkSize, 1);
    });

    test('creates with custom values', () {
      const AnimationConfig config = AnimationConfig(
        mode: AnimationMode.character,
        charDelay: Duration(milliseconds: 20),
        chunkSize: 5,
      );
      expect(config.mode, AnimationMode.character);
      expect(config.charDelay, const Duration(milliseconds: 20));
      expect(config.chunkSize, 5);
    });

    test('copyWith creates new instance with updated values', () {
      const AnimationConfig config1 = AnimationConfig();
      final AnimationConfig config2 = config1.copyWith(
        mode: AnimationMode.token,
        chunkSize: 10,
      );
      expect(config2.mode, AnimationMode.token);
      expect(config2.chunkSize, 10);
      expect(config2.charDelay, config1.charDelay);
    });
  });

  group('MarkdownTypingController', () {
    test('initializes with empty text', () {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: '',
      );
      expect(controller.text, '');
      expect(controller.isComplete, true);
      expect(controller.progress, 1.0);
    });

    test('initializes with text', () {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: 'Hello',
      );
      expect(controller.text, '');
      expect(controller.isComplete, false);
      expect(controller.progress, 0.0);
    });

    test('resets to beginning', () {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: 'Hello',
      );
      controller.jumpToEnd();
      expect(controller.isComplete, true);
      controller.reset();
      expect(controller.text, '');
      expect(controller.isComplete, false);
    });

    test('jumps to end', () {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: 'Hello',
      );
      controller.jumpToEnd();
      expect(controller.text, 'Hello');
      expect(controller.isComplete, true);
    });

    test('pauses and resumes', () async {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: 'Hello World',
        config: const AnimationConfig(
          mode: AnimationMode.character,
          charDelay: Duration(milliseconds: 10),
        ),
      );
      controller.start();
      await Future.delayed(const Duration(milliseconds: 30));
      controller.pause();
      expect(controller.isPaused, true);
      final String textBeforeResume = controller.text;
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.text, textBeforeResume);
      await controller.resume();
      await Future.delayed(const Duration(milliseconds: 30));
      expect(controller.text.length, greaterThan(textBeforeResume.length));
    });

    test('stops animation', () async {
      final MarkdownTypingController controller = MarkdownTypingController(
        fullText: 'Hello',
        config: const AnimationConfig(
          mode: AnimationMode.character,
          charDelay: Duration(milliseconds: 10),
        ),
      );
      controller.start();
      await Future.delayed(const Duration(milliseconds: 20));
      controller.stop();
      expect(controller.isRunning, false);
    });
  });

  group('AnimatedMarkdown Widget', () {
    testWidgets('renders markdown text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '# Hello\nThis is a test',
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('animates text character by character', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: 'Hello',
              config: const AnimationConfig(
                mode: AnimationMode.character,
                charDelay: Duration(milliseconds: 10),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Hello'), findsNothing);
      // Pump frames to trigger post-frame callback and start animation
      await tester.pump();
      // Advance time to allow animation to progress (10ms delay per character)
      // Pump multiple times to ensure animation progresses
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump();
      // Verify that at least one character has appeared
      expect(find.text('H'), findsOneWidget);
    });

    testWidgets('renders inline button in paragraph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: 'Click [[button:Click Me]] here',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline chip in paragraph', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: 'Tag: [[chip:Important]]',
              customBuilders: {'chip': ChipBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Important'), findsOneWidget);
      expect(find.byType(ActionChip), findsOneWidget);
    });
  });

  group('Inline Widgets in List Items', () {
    testWidgets('renders inline button in unordered list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '- List item with [[button:Action]] button',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline chip in unordered list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '- Item with [[chip:Tag]] here',
              customBuilders: {'chip': ChipBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tag'), findsOneWidget);
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('renders inline button in ordered list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '1. First item with [[button:Click]]',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Click'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline widgets in nested list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '''
- Parent item
  - Nested item with [[button:Nested]] button
  - Another nested with [[chip:Tag]] chip
''',
              customBuilders: {
                'button': ButtonBuilder(),
                'chip': ChipBuilder(),
              },
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nested'), findsOneWidget);
      expect(find.text('Tag'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('renders multiple inline widgets in single list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown:
                  '- Item with [[chip:First]] and [[chip:Second]] and [[button:Action]]',
              customBuilders: {
                'button': ButtonBuilder(),
                'chip': ChipBuilder(),
              },
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(2));
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline widget at start of list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '- [[button:Start]] item text',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline widget in middle of list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '- Start text [[button:Middle]] end text',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Middle'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('renders inline widget at end of list item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedMarkdown(
              markdown: '- Item text [[button:End]]',
              customBuilders: {'button': ButtonBuilder()},
              config: const AnimationConfig(
                charDelay: Duration.zero,
                wordDelay: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('End'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
