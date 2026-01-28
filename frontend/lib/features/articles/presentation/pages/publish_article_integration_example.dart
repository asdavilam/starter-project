/// Ejemplo de integración de PublishArticlePage
///
/// Este archivo muestra cómo integrar PublishArticlePage en tu aplicación
/// incluyendo la configuración del BlocProvider y la navegación

/*

PASO 1: Registrar dependencias en injection_container.dart
============================================================

// Agregar al final de initializeDependencies():

// UseCases - Publish Article
sl.registerSingleton<PublishArticleUseCase>(
  PublishArticleUseCase(),
);

// Blocs - Publish Article
sl.registerFactory<PublishArticleBloc>(
  () => PublishArticleBloc(sl())
);


PASO 2: Navegar a PublishArticlePage desde un botón
====================================================

// Ejemplo en tu HomePage o cualquier widget:

FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => sl<PublishArticleBloc>(),
          child: const PublishArticlePage(),
        ),
      ),
    );
  },
  child: const Icon(Icons.add),
  tooltip: 'Crear artículo',
)


PASO 3: Importaciones necesarias
=================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/bloc.dart';
import 'package:news_app_clean_architecture/injection_container.dart';


PASO 4: Configuración de permisos (si es necesario)
===================================================

Android (android/app/src/main/AndroidManifest.xml):
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

iOS (ios/Runner/Info.plist):
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tu galería para seleccionar imágenes de artículos</string>


NOTAS IMPORTANTES:
==================
1. El PublishArticleBloc solo interactúa con PublishArticleUseCase (Clean Architecture)
2. La página maneja automáticamente la navegación de regreso al success
3. Los estados de carga y error se muestran con SnackBars
4. El formulario incluye validaciones para todos los campos
5. La imagen es opcional - si no se selecciona, usa una imagen por defecto

*/
