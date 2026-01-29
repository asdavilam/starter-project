import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_sources/local/reading_settings_local_data_source.dart';
import '../../domain/entities/reading_settings.dart';

/// Cubit for managing reading preferences
/// Automatically persists all changes to local storage
class ReadingSettingsCubit extends Cubit<ReadingSettings> {
  final ReadingSettingsLocalDataSource _localDataSource;

  ReadingSettingsCubit({
    required ReadingSettingsLocalDataSource localDataSource,
  })  : _localDataSource = localDataSource,
        super(ReadingSettings.defaults) {
    _loadSettings();
  }

  /// Load settings from local storage on initialization
  Future<void> _loadSettings() async {
    try {
      final settings = await _localDataSource.loadSettings();
      if (settings != null) {
        emit(settings);
      }
    } catch (e) {
      // If loading fails, keep defaults
    }
  }

  /// Update font size
  Future<void> updateFontSize(double size) async {
    final newSettings = state.copyWith(fontSize: size);
    emit(newSettings);
    await _persist(newSettings);
  }

  /// Update font family
  Future<void> updateFontFamily(FontFamily family) async {
    final newSettings = state.copyWith(fontFamily: family);
    emit(newSettings);
    await _persist(newSettings);
  }

  /// Update theme mode
  Future<void> updateThemeMode(ReadingThemeMode mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    emit(newSettings);
    await _persist(newSettings);
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    emit(ReadingSettings.defaults);
    await _localDataSource.clearSettings();
  }

  /// Persist settings to local storage
  Future<void> _persist(ReadingSettings settings) async {
    try {
      await _localDataSource.saveSettings(settings);
    } catch (e) {
      // Persistence error - non-critical, settings still work for current session
    }
  }
}
