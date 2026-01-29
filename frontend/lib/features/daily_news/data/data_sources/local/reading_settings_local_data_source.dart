import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/reading_settings_model.dart';
import '../../../domain/entities/reading_settings.dart';

/// Local data source for reading settings persistence
abstract class ReadingSettingsLocalDataSource {
  /// Load saved reading settings
  Future<ReadingSettings?> loadSettings();

  /// Save reading settings
  Future<void> saveSettings(ReadingSettings settings);

  /// Clear all settings (reset to defaults)
  Future<void> clearSettings();
}

/// Implementation using SharedPreferences
class ReadingSettingsLocalDataSourceImpl
    implements ReadingSettingsLocalDataSource {
  static const String _key = 'reading_settings';
  final SharedPreferences _prefs;

  ReadingSettingsLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<ReadingSettings?> loadSettings() async {
    try {
      final jsonString = _prefs.getString(_key);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ReadingSettingsModel.fromJson(json).toEntity();
    } catch (e) {
      // If parsing fails, return null (will use defaults)
      return null;
    }
  }

  @override
  Future<void> saveSettings(ReadingSettings settings) async {
    final model = ReadingSettingsModel.fromEntity(settings);
    final jsonString = jsonEncode(model.toJson());
    await _prefs.setString(_key, jsonString);
  }

  @override
  Future<void> clearSettings() async {
    await _prefs.remove(_key);
  }
}
