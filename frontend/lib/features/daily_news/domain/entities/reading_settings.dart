import 'package:equatable/equatable.dart';

/// Theme modes for reading experience
enum ReadingThemeMode {
  normal, // Standard light theme
  dark, // Dark mode
  sepia, // Sepia/warm tone for comfortable reading
}

/// Font family options for reading
enum FontFamily {
  sansSerif, // Modern, clean fonts (Roboto, Inter)
  serif, // Traditional, book-like fonts (Merriweather, Lora)
}

/// Entity representing user's reading preferences
class ReadingSettings extends Equatable {
  final double fontSize; // Font size in logical pixels (14-32)
  final FontFamily fontFamily; // Serif or Sans-Serif
  final ReadingThemeMode themeMode; // Normal, Dark, or Sepia

  const ReadingSettings({
    required this.fontSize,
    required this.fontFamily,
    required this.themeMode,
  });

  /// Default reading settings
  static const ReadingSettings defaults = ReadingSettings(
    fontSize: 16.0,
    fontFamily: FontFamily.sansSerif,
    themeMode: ReadingThemeMode.normal,
  );

  /// Create copy with updated fields
  ReadingSettings copyWith({
    double? fontSize,
    FontFamily? fontFamily,
    ReadingThemeMode? themeMode,
  }) {
    return ReadingSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [fontSize, fontFamily, themeMode];
}
