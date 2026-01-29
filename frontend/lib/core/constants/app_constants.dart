/// App-wide constants for Clean Architecture consistency
/// Centralizes magic numbers, strings, and configuration values

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ============ UI Dimensions ============
  static const double articleDetailExpandedHeight = 400.0;
  static const double contentPadding = 20.0;
  static const double contentPaddingSmall = 12.0;
  static const double contentPaddingLarge = 24.0;
  static const double bottomBarVerticalPadding = 12.0;
  static const double bottomBarHorizontalPadding = 20.0;
  static const double buttonBorderRadius = 30.0;
  static const double cardBorderRadius = 16.0;
  static const double iconButtonSize = 28.0;
  static const double iconButtonPadding = 12.0;
  static const double listItemHeight = 120.0;

  // ============ Typography ============
  static const double titleFontSize = 24.0;
  static const double headlineFontSize = 20.0;
  static const double bodyFontSize = 18.0;
  static const double bodySmallFontSize = 16.0;
  static const double metadataFontSize = 13.0;
  static const double chipFontSize = 11.0;
  static const double buttonFontSize = 16.0;
  static const String primaryFontFamily = 'Butler';
  static const double lineHeightNormal = 1.5;
  static const double lineHeightExpanded = 1.6;
  static const double lineHeightCompact = 1.2;

  // ============ Spacing ============
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // ============ Icon Sizes ============
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 50.0;
  static const double iconSizeXXLarge = 60.0;
  static const double iconSizeHuge = 80.0;

  // ============ Elevation (Shadow) ============
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // ============ Opacity ============
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityLight = 0.87;
  static const double opacityFull = 1.0;

  // ============ Durations (Milliseconds) ============
  static const int animationDurationFast = 150;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
  static const int splashDuration = 2000;
  static const int snackBarDuration = 3000;
  static const int refreshIndicatorDuration = 1000;

  // ============ Database Tables (Hive) ============
  static const String articlesBoxName = 'articles_box';
  static const String draftsBoxName = 'drafts_box';

  // ============ API ============
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;

  // ============ Validation ============
  static const int minTitleLength = 5;
  static const int maxTitleLength = 200;
  static const int minContentLength = 50;

  // ============ Messages ============
  static const String articleSavedMessage = 'Artículo guardado en marcadores';
  static const String articleRemovedMessage = 'Artículo eliminado de guardados';
  static const String articleNotFoundMessage =
      'No se pudo encontrar el artículo';
  static const String genericErrorMessage =
      'Ha ocurrido un error. Intenta de nuevo.';
  static const String noContentMessage = 'No hay contenido disponible.';
  static const String loadingMessage = 'Cargando...';
  static const String emptyStateMessage = 'No hay artículos para mostrar.';
  static const String savedArticlesEmptyMessage = 'Sin artículos guardados';
  static const String draftsEmptyMessage = 'Sin borradores';
  static const String noInternetMessage = 'Sin conexión a internet';

  // ============ Routes ============
  static const String homeRoute = '/';
  static const String articleDetailsRoute = '/article-details';
  static const String savedArticlesRoute = '/saved-articles';
  static const String draftsRoute = '/drafts';
  static const String accountRoute = '/account';
  static const String publishArticleRoute = '/publish-article';

  // ============ Supported Languages ============
  static const Map<String, String> supportedTranslationLanguages = {
    'Spanish': '🇪🇸 Español (Spanish)',
    'English': '🇺🇸 Inglés (English)',
    'French': '🇫🇷 Francés (Français)',
    'German': '🇩🇪 Alemán (Deutsch)',
  };

  static const Map<String, String> supportedTTSLanguages = {
    'Spanish': '🇪🇸 Español (Spanish)',
    'English': '🇺🇸 Inglés (English)',
  };

  // ============ UI Strings (Centralized) ============
  static const String chooseLanguageTitle = 'Seleccionar Idioma';
  static const String listenToNewsTitle = 'Escuchar Noticia';
  static const String playingInSpanish = 'Reproduciendo en Español...';
  static const String playingInEnglish = 'Playing in English...';
  static const String myAccountTitle = 'Mi Cuenta';
  static const String subscriptionSimulationTitle = 'Simulación de Suscripción';
  static const String premiumStatusLabel = '✨ ESTADO PREMIUM';
  static const String freeStatusLabel = '👤 ESTADO GRATUITO';
  static const String availableCreditsLabel = 'Créditos disponibles';
  static const String upgradeButtonLabel = 'Obtener Premium';
  static const String downgradeButtonLabel = 'Bajar a Free';
  static const String resetButtonLabel = 'Resetear';
  static const String deleteArticleTitle = 'Eliminar artículo';
  static const String deleteArticleContent =
      '¿Estás seguro de que deseas eliminar este artículo de forma definitiva?';
  static const String deleteDraftTitle = 'Eliminar borrador';
  static const String deleteDraftContent =
      '¿Estás seguro de que deseas eliminar este borrador? Esta acción no se puede deshacer.';
  static const String cancelAction = 'Cancelar';
  static const String deleteAction = 'Eliminar';
  static const String draftDeletedMessage = 'Borrador eliminado';

  // ============ Nav Bar Labels ============
  static const String navHome = 'Inicio';
  static const String navSaved = 'Guardados';
  static const String navDrafts = 'Borradores';
  static const String navAccount = 'Cuenta';
}
