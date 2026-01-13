import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/animation_config.dart';
import '../models/animation_mode.dart';
import '../utils/string_utils.dart';

/// Controller that manages typing animation for markdown text.
class MarkdownTypingController extends ChangeNotifier {
  /// Stream of markdown text chunks to animate.
  final Stream<String>? _stream;

  /// Animation configuration.
  final AnimationConfig config;

  /// Accumulated text from stream or initial text.
  String _fullText = '';

  /// Stream subscription for listening to incoming chunks.
  StreamSubscription<String>? _streamSubscription;

  /// Whether the stream has completed.
  bool _streamCompleted = false;

  /// Completer to signal when new data arrives from stream.
  Completer<void>? _dataAvailableCompleter;

  String _currentText = '';
  int _index = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;
  Completer<void>? _completer;

  /// Creates a [MarkdownTypingController] with the given text and config.
  MarkdownTypingController({
    String? fullText,
    Stream<String>? stream,
    AnimationConfig? config,
  }) : _stream = stream,
       config = config ?? const AnimationConfig() {
    if (stream != null) {
      _fullText = '';
      _initializeStream();
    } else {
      _fullText = fullText ?? '';
    }
  }

  /// Full text to animate (current accumulated text).
  String get fullText => _fullText;

  /// Current displayed text.
  String get text => _currentText;

  /// Whether the animation is currently running.
  bool get isRunning => _isRunning;

  /// Whether the animation is paused.
  bool get isPaused => _isPaused;

  /// Current progress (0.0 to 1.0).
  double get progress {
    if (_fullText.isEmpty) return 1.0;
    return _index / _fullText.length;
  }

  /// Whether the animation is complete.
  bool get isComplete {
    if (_stream != null) {
      return _index >= _fullText.length && _streamCompleted;
    }
    return _index >= _fullText.length;
  }

  /// Starts the typing animation.
  Future<void> start() async {
    if (_isRunning && !_isPaused) return;
    if (isComplete) return;
    _isRunning = true;
    _isPaused = false;
    _completer = Completer<void>();
    await _animate();
    await _completer?.future;
  }

  /// Pauses the typing animation.
  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Resumes the typing animation.
  Future<void> resume() async {
    if (!_isPaused) return;
    _isPaused = false;
    await _animate();
  }

  /// Stops the typing animation.
  void stop() {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    _timer = null;
    _completer?.complete();
    _completer = null;
    _dataAvailableCompleter?.complete();
    _dataAvailableCompleter = null;
  }

  /// Resets the animation to the beginning.
  void reset() {
    stop();
    _currentText = '';
    _index = 0;
    notifyListeners();
  }

  /// Jumps to the end of the animation.
  void jumpToEnd() {
    stop();
    _currentText = _fullText;
    _index = _fullText.length;
    notifyListeners();
  }

  /// Initializes stream subscription to listen for incoming chunks.
  void _initializeStream() {
    if (_stream == null) return;
    _streamSubscription = _stream.listen(
      (String chunk) {
        _fullText += chunk;
        notifyListeners();
        // Signal that new data is available
        if (_dataAvailableCompleter != null &&
            !_dataAvailableCompleter!.isCompleted) {
          _dataAvailableCompleter!.complete();
          _dataAvailableCompleter = null;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _streamCompleted = true;
        if (_dataAvailableCompleter != null &&
            !_dataAvailableCompleter!.isCompleted) {
          _dataAvailableCompleter!.complete();
          _dataAvailableCompleter = null;
        }
      },
      onDone: () {
        _streamCompleted = true;
        if (_dataAvailableCompleter != null &&
            !_dataAvailableCompleter!.isCompleted) {
          _dataAvailableCompleter!.complete();
          _dataAvailableCompleter = null;
        }
      },
    );
  }

  Future<void> _animate() async {
    while (_isRunning && !_isPaused) {
      // Check if we have more data to animate
      if (_index >= _fullText.length) {
        // If using stream and it's not completed, wait for more data
        if (_stream != null && !_streamCompleted) {
          _dataAvailableCompleter = Completer<void>();
          await _dataAvailableCompleter!.future;
          // After data arrives, continue the loop
          continue;
        }
        // Stream completed or using static text, finish animation
        _isRunning = false;
        _completer?.complete();
        _completer = null;
        return;
      }
      final int chunkSize = _getChunkSize();
      final String chunk = _getChunk(chunkSize);
      if (chunk.isEmpty) {
        // No chunk available, wait a bit and try again
        await Future.microtask(() {});
        continue;
      }
      _currentText += chunk;
      _index += chunk.length;
      notifyListeners();
      if (_index >= _fullText.length) {
        // Check if stream is still active
        if (_stream != null && !_streamCompleted) {
          // Wait for more data
          _dataAvailableCompleter = Completer<void>();
          await _dataAvailableCompleter!.future;
          continue;
        }
        _isRunning = false;
        _completer?.complete();
        _completer = null;
        return;
      }
      final Duration delay = _getDelay();
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      } else {
        await Future.microtask(() {});
      }
    }
    if (!_isPaused) {
      _isRunning = false;
      _completer?.complete();
      _completer = null;
    }
  }

  int _getChunkSize() {
    if (config.mode == AnimationMode.custom) {
      return config.chunkSize;
    }
    if (config.mode == AnimationMode.character) {
      return config.chunkSize;
    }
    if (config.mode == AnimationMode.word) {
      return config.chunkSize;
    }
    if (config.mode == AnimationMode.token) {
      return config.chunkSize;
    }
    return 1;
  }

  String _getChunk(int size) {
    if (_index >= _fullText.length) return '';
    if (config.mode == AnimationMode.character) {
      final int end = (_index + size).clamp(0, _fullText.length);
      final String chunk = StringUtils.safeSubstring(_fullText, _index, end);
      return StringUtils.sanitizeUtf16(chunk);
    }
    if (config.mode == AnimationMode.word) {
      final String remaining = StringUtils.safeSubstring(
        _fullText,
        _index,
        _fullText.length,
      );
      if (remaining.isEmpty) return '';
      // Use regex to match words with their following whitespace, preserving newlines
      // Pattern matches: word (non-whitespace) + following whitespace (spaces/tabs/newlines)
      // This preserves markdown structure by keeping newlines and spacing intact
      // The pattern \S+\s* matches a word followed by any whitespace (including newlines)
      final RegExp wordPattern = RegExp(r'\S+\s*');
      final Iterable<Match> matches = wordPattern.allMatches(remaining);
      if (matches.isEmpty) {
        // If no word matches, return any remaining whitespace/newlines
        return StringUtils.sanitizeUtf16(remaining);
      }
      final int wordsToTake = size.clamp(1, matches.length);
      final List<Match> matchesToTake = matches.take(wordsToTake).toList();
      if (matchesToTake.isEmpty) return '';
      // Get the end position of the last match
      final int endPos = matchesToTake.last.end;
      // Extract the chunk preserving original structure
      final String chunk = StringUtils.safeSubstring(remaining, 0, endPos);
      return StringUtils.sanitizeUtf16(chunk);
    }
    if (config.mode == AnimationMode.token) {
      final String remaining = StringUtils.safeSubstring(
        _fullText,
        _index,
        _fullText.length,
      );
      if (remaining.isEmpty) return '';
      // Use regex to match tokens (non-whitespace sequences) with their following whitespace
      // Pattern matches: token (non-whitespace) + following whitespace (spaces/tabs/newlines)
      // This preserves markdown structure by keeping newlines and spacing intact
      // The pattern \S+\s* matches a token followed by any whitespace (including newlines)
      final RegExp tokenPattern = RegExp(r'\S+\s*');
      final Iterable<Match> matches = tokenPattern.allMatches(remaining);
      if (matches.isEmpty) {
        // If no token matches, return any remaining whitespace/newlines
        return StringUtils.sanitizeUtf16(remaining);
      }
      final int tokensToTake = size.clamp(1, matches.length);
      final List<Match> matchesToTake = matches.take(tokensToTake).toList();
      if (matchesToTake.isEmpty) return '';
      // Get the end position of the last match
      final int endPos = matchesToTake.last.end;
      // Extract the chunk preserving original structure
      final String chunk = StringUtils.safeSubstring(remaining, 0, endPos);
      return StringUtils.sanitizeUtf16(chunk);
    }
    if (config.mode == AnimationMode.custom) {
      final int end = (_index + size).clamp(0, _fullText.length);
      final String chunk = StringUtils.safeSubstring(_fullText, _index, end);
      return StringUtils.sanitizeUtf16(chunk);
    }
    final String chunk = StringUtils.safeSubstring(
      _fullText,
      _index,
      (_index + 1).clamp(0, _fullText.length),
    );
    return StringUtils.sanitizeUtf16(chunk);
  }

  Duration _getDelay() {
    if (_fullText.length > config.throttleThreshold) {
      return Duration(
        milliseconds: (config.charDelay.inMilliseconds * 2).clamp(0, 100),
      );
    }
    switch (config.mode) {
      case AnimationMode.character:
        return config.charDelay;
      case AnimationMode.word:
        return config.wordDelay;
      case AnimationMode.token:
        return config.tokenDelay;
      case AnimationMode.custom:
        return config.charDelay;
    }
  }

  @override
  void dispose() {
    stop();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _dataAvailableCompleter?.complete();
    _dataAvailableCompleter = null;
    super.dispose();
  }
}
