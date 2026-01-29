import '../../domain/entities/reading_settings.dart';

/// Data model for ReadingSettings with JSON serialization
class ReadingSettingsModel extends ReadingSettings {
  const ReadingSettingsModel({
    required super.fontSize,
    required super.fontFamily,
    required super.themeMode,
  });

  /// Convert from domain entity
  factory ReadingSettingsModel.fromEntity(ReadingSettings settings) {
    return ReadingSettingsModel(
      fontSize: settings.fontSize,
      fontFamily: settings.fontFamily,
      themeMode: settings.themeMode,
    );
  }

  /// Create from JSON
  factory ReadingSettingsModel.fromJson(Map<String, dynamic> json) {
    return ReadingSettingsModel(
      fontSize: (json['fontSize'] as num?)?.toDouble() ??
          ReadingSettings.defaults.fontSize,
      fontFamily: _parseFontFamily(json['fontFamily'] as String?),
      themeMode: _parseThemeMode(json['themeMode'] as String?),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily.name,
      'themeMode': themeMode.name,
    };
  }

  /// Convert to domain entity
  ReadingSettings toEntity() {
    return ReadingSettings(
      fontSize: fontSize,
      fontFamily: fontFamily,
      themeMode: themeMode,
    );
  }

  /// Parse font family from string
  static FontFamily _parseFontFamily(String? value) {
    switch (value) {
      case 'serif':
        return FontFamily.serif;
      case 'sansSerif':
      default:
        return FontFamily.sansSerif;
    }
  }

  /// Parse theme mode from string
  static ReadingThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ReadingThemeMode.dark;
      case 'sepia':
        return ReadingThemeMode.sepia;
      case 'normal':
      default:
        return ReadingThemeMode.normal;
    }
  }
}
