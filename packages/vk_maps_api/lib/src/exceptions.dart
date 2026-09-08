/// Ошибка обращения к сервисам VK Карт.
class VkMapsApiException implements Exception {
  /// Создаёт ошибку.
  const VkMapsApiException(
    this.message, {
    this.statusCode,
    this.endpoint,
    this.body,
  });

  /// Человекочитаемое описание.
  final String message;

  /// HTTP-код ответа, если ответ вообще пришёл.
  final int? statusCode;

  /// Точка вызова, на которой произошла ошибка.
  final String? endpoint;

  /// Тело ответа, если оно есть: сервис описывает формат ошибок неполно,
  /// поэтому сырое тело сохраняется для разбора на месте.
  final String? body;

  /// Превышен ли лимит частоты запросов (50 запросов в секунду на ключ).
  bool get isRateLimited => statusCode == 429;

  /// Отклонён ли ключ доступа.
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('VkMapsApiException: $message');
    if (endpoint != null) {
      buffer.write(' (${endpoint!})');
    }
    if (statusCode != null) {
      buffer.write(' [HTTP $statusCode]');
    }
    return buffer.toString();
  }
}
