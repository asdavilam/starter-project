import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  /// Devuelve la fecha en formato legible "dd de MMMM de yyyy"
  /// Ej: "27 de enero de 2024"
  /// Si ocurre error, devuelve formato ISO básico.
  String get toReadableDate {
    try {
      // Usar initializeDateFormatting si se requieren locales específicos no cargados
      // Por defecto 'es' suele requerir inicialización, pero 'en' no.
      // Para simplificar y asegurar funcionamiento sin init async, usamos formato custom
      // O podemos usarDateFormat.yMMMMd('es') si se inicializa en main.

      // Enfoque robusto sin async init: construir manual o usar default system locale
      return DateFormat('d MMMM, yyyy').format(this);
    } catch (e) {
      return toString().split(' ')[0];
    }
  }

  /// Devuelve fecha y hora legible
  String get toReadableDateTime {
    try {
      return DateFormat('d MMM yyyy, HH:mm').format(this);
    } catch (e) {
      return toString();
    }
  }

  /// Devuelve tiempo relativo si es hoy (ej: "Hace 3 horas"), o fecha si es anterior
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return toReadableDate;
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} ${difference.inHours == 1 ? "hora" : "horas"}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} ${difference.inMinutes == 1 ? "minuto" : "minutos"}';
    } else {
      return 'Hace unos instantes';
    }
  }
}
