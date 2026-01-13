/// Utility functions for safe UTF-16 string operations.
class StringUtils {
  /// Validates if a string is well-formed UTF-16.
  ///
  /// Returns true if the string is valid UTF-16, false otherwise.
  static bool isValidUtf16(String text) {
    try {
      // Try to create a TextSpan with the text to validate it
      // This will throw if the string is not well-formed UTF-16
      text.codeUnits;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safely splits a string into individual code points (Unicode characters).
  ///
  /// This respects UTF-16 surrogate pairs and will not break multi-byte characters.
  /// Returns a list of strings, each containing a single code point.
  static List<String> splitByCodePoints(String text) {
    if (text.isEmpty) {
      return [];
    }
    final List<String> codePoints = [];
    final Runes runes = text.runes;
    for (final int rune in runes) {
      codePoints.add(String.fromCharCode(rune));
    }
    return codePoints;
  }

  /// Safely extracts a substring without breaking UTF-16 surrogate pairs.
  ///
  /// [start] and [end] are indices in code units, but the function ensures
  /// that surrogate pairs are not split. Returns a valid UTF-16 string.
  static String safeSubstring(String text, int start, int end) {
    if (start < 0) start = 0;
    if (end > text.length) end = text.length;
    if (start >= end) return '';
    if (start == 0 && end == text.length) return text;
    // Check if we're splitting a surrogate pair at the start
    if (start > 0 && start < text.length) {
      final int codeUnit = text.codeUnitAt(start);
      if (_isLowSurrogate(codeUnit) && _isHighSurrogate(text.codeUnitAt(start - 1))) {
        // We're in the middle of a surrogate pair, move start back
        start--;
      }
    }
    // Check if we're splitting a surrogate pair at the end
    if (end > 0 && end < text.length) {
      final int codeUnit = text.codeUnitAt(end - 1);
      if (_isHighSurrogate(codeUnit) && end < text.length && _isLowSurrogate(text.codeUnitAt(end))) {
        // We're in the middle of a surrogate pair, move end forward
        end++;
      }
    }
    // Ensure end doesn't exceed length after adjustment
    if (end > text.length) end = text.length;
    if (start >= end) return '';
    return text.substring(start, end);
  }

  /// Checks if a code unit is a high surrogate (leading surrogate).
  static bool _isHighSurrogate(int codeUnit) {
    return codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
  }

  /// Checks if a code unit is a low surrogate (trailing surrogate).
  static bool _isLowSurrogate(int codeUnit) {
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }

  /// Sanitizes a string to ensure it's valid UTF-16.
  ///
  /// Removes any invalid surrogate pairs (standalone high or low surrogates)
  /// to ensure the string can be safely used in TextSpan and other text widgets.
  /// Returns a sanitized version of the string.
  static String sanitizeUtf16(String text) {
    if (text.isEmpty) return text;
    // Filter out invalid surrogate pairs
    final List<int> validCodeUnits = [];
    for (int i = 0; i < text.length; i++) {
      final int codeUnit = text.codeUnitAt(i);
      if (_isHighSurrogate(codeUnit)) {
        // Check if next unit is a valid low surrogate
        if (i + 1 < text.length && _isLowSurrogate(text.codeUnitAt(i + 1))) {
          // Valid surrogate pair - add both
          validCodeUnits.add(codeUnit);
          validCodeUnits.add(text.codeUnitAt(i + 1));
          i++; // Skip the low surrogate as we've already added it
        }
        // Otherwise, skip the high surrogate (invalid - no matching low surrogate)
      } else if (_isLowSurrogate(codeUnit)) {
        // Skip standalone low surrogates (invalid - no matching high surrogate)
        continue;
      } else {
        // Regular code unit - add it
        validCodeUnits.add(codeUnit);
      }
    }
    return String.fromCharCodes(validCodeUnits);
  }
}
