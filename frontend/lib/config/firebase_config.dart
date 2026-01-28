import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Conectar a emuladores locales en modo debug
  // TODO: Habilitar configuración dinámica si es necesario
  // Por ahora forzamos Cloud Mode para estabilidad
  if (kDebugMode) {
    // debugPrint('🚀 Firebase Cloud Mode (Production)');
  }
}
