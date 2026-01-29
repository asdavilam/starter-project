import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/reading_settings.dart';
import '../../../cubit/reading_settings_cubit.dart';

/// Bottom sheet for reading customization settings
class ReadingSettingsBottomSheet extends StatelessWidget {
  const ReadingSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettings>(
      builder: (context, settings) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.spacing24),
              _buildFontSizeSlider(context, settings),
              const SizedBox(height: AppConstants.spacing24),
              _buildFontFamilySelector(context, settings),
              const SizedBox(height: AppConstants.spacing24),
              _buildThemeModeSelector(context, settings),
              const SizedBox(height: AppConstants.spacing16),
              _buildResetButton(context),
              const SizedBox(height: AppConstants.spacing16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.tune, size: 24),
        const SizedBox(width: AppConstants.spacing8),
        const Text(
          'Ajustes de Lectura',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, ReadingSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tamaño de Letra',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${settings.fontSize.round()}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 14.0,
          max: 32.0,
          divisions: 18,
          label: settings.fontSize.round().toString(),
          onChanged: (value) {
            context.read<ReadingSettingsCubit>().updateFontSize(value);
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(
      BuildContext context, ReadingSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Fuente',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacing8),
        ToggleButtons(
          isSelected: [
            settings.fontFamily == FontFamily.sansSerif,
            settings.fontFamily == FontFamily.serif,
          ],
          onPressed: (index) {
            final family = index == 0 ? FontFamily.sansSerif : FontFamily.serif;
            context.read<ReadingSettingsCubit>().updateFontFamily(family);
          },
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Sans Serif'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('Serif'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeModeSelector(
      BuildContext context, ReadingSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tema de Lectura',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacing8),
        Wrap(
          spacing: 8,
          children: [
            _buildThemeChip(
              context,
              label: 'Normal',
              mode: ReadingThemeMode.normal,
              isSelected: settings.themeMode == ReadingThemeMode.normal,
            ),
            _buildThemeChip(
              context,
              label: 'Oscuro',
              mode: ReadingThemeMode.dark,
              isSelected: settings.themeMode == ReadingThemeMode.dark,
            ),
            _buildThemeChip(
              context,
              label: 'Sepia',
              mode: ReadingThemeMode.sepia,
              isSelected: settings.themeMode == ReadingThemeMode.sepia,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeChip(
    BuildContext context, {
    required String label,
    required ReadingThemeMode mode,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        context.read<ReadingSettingsCubit>().updateThemeMode(mode);
      },
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<ReadingSettingsCubit>().resetToDefaults();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Restaurar Valores Predeterminados'),
      ),
    );
  }
}
