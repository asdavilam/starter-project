/// Excepción personalizada para errores del servidor
///
/// Se lanza cuando ocurre un error en las llamadas a servicios externos
/// como Firebase, APIs REST, etc.
/// El repositorio debe capturar esta excepción y convertirla en DataState.error
class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({
    required this.message,
    this.code,
  });

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (code: $code)' : ''}';
}
