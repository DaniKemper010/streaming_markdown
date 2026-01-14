import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

/// Base class for custom markdown builders.
abstract class CustomMarkdownBuilder extends MarkdownElementBuilder {
  /// Builds a widget from the markdown element.
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? style) {
    // #region agent log
    try {
      final logData = {
        'sessionId': 'debug-session',
        'runId': 'run8',
        'hypothesisId': 'L',
        'location': 'lib/src/builders/custom_markdown_builder.dart:11',
        'message': 'CustomMarkdownBuilder.visitElementAfter called',
        'data': {
          'elementTag': element.tag,
          'elementTextContent': element.textContent,
          'elementChildrenCount': element.children?.length ?? 0,
          'elementAttributes': element.attributes.toString(),
          'hasStyle': style != null,
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final logFile = '/Users/danikemper/streaming_markdown/.cursor/debug.log';
      final logLine = '${logData.toString()}\n';
      (() async {
        try {
          await Future(() {
            final file = File(logFile);
            file.writeAsStringSync(logLine, mode: FileMode.append);
          });
        } catch (e) {
          // Ignore logging errors
        }
      })();
    } catch (e) {
      // Ignore logging errors
    }
    // #endregion
    return buildWidget(element, style);
  }

  /// Builds the widget for the given element.
  Widget? buildWidget(md.Element element, TextStyle? style);
}

/// Base class for inline widget builders.
abstract class InlineBuilder extends CustomMarkdownBuilder {
  @override
  Widget? buildWidget(md.Element element, TextStyle? style) {
    return buildInline(element, style);
  }

  /// Builds an inline widget that can appear within text and list items.
  Widget buildInline(md.Element element, TextStyle? style);
}
