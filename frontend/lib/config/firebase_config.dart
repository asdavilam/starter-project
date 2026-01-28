import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Conectar a emuladores locales en modo debug
  /*
  // COMENTADO: Usar Cloud para evitar problemas de red locales
  if (kDebugMode) {
    try {
      // Android emulator: usa 10.0.2.2 (alias para localhost de la máquina host)
      // iOS simulator / Desktop: usa 'localhost' o '127.0.0.1'
      const emulatorHost = '10.0.2.2'; // Cambiar a 'localhost' para iOS/Desktop
      
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
      // ignore: avoid_print
      print('🔥 Firebase Emulators conectados ($emulatorHost:8080, $emulatorHost:9199)');
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error conectando emuladores: $e');
      // ignore: avoid_print
      print('💡 Asegúrate de ejecutar: firebase emulators:start');
    }
  } else {
    // ignore: avoid_print
    print('🚀 Firebase Cloud Mode (Production)');
  }
  */

  // ignore: avoid_print
  print('🚀 Firebase Cloud Mode (Production) - Emulators Disabled');

  // ignore: avoid_print
  print('✅ Firebase Initialized Successfully');
}
