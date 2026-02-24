import 'dart:convert';
import 'package:http/http.dart' as http;

class TrackingResult {
  final String status;
  final List<String> steps;

  const TrackingResult({required this.status, required this.steps});
}

class DeliveryService {
  /// Nova Poshta API v2
  static Future<TrackingResult> trackNovaPoshta({
    required String apiKey,
    required String trackingNumber,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('API-ключ Нової Пошти не налаштований. '
          'Будь ласка, додайте його в Налаштування → API інтеграції.');
    }

    final body = jsonEncode({
      'apiKey': apiKey,
      'modelName': 'TrackingDocument',
      'calledMethod': 'getStatusDocuments',
      'methodProperties': {
        'Documents': [
          {'DocumentNumber': trackingNumber}
        ]
      },
    });

    final response = await http
        .post(
          Uri.parse('https://api.novaposhta.ua/v2.0/json/'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'Помилка з\'єднання з Nova Poshta (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      final errors = (data['errors'] as List<dynamic>? ?? []).join(', ');
      throw Exception('Nova Poshta: $errors');
    }

    final docList = data['data'] as List<dynamic>? ?? [];
    if (docList.isEmpty) {
      throw Exception('Посилку з номером "$trackingNumber" не знайдено.');
    }

    final doc = docList.first as Map<String, dynamic>;
    final status = doc['Status'] as String? ?? 'Невідомо';

    // Build history from available fields
    final steps = <String>[];
    final cityFrom = doc['CitySender'] as String?;
    final cityTo = doc['CityRecipient'] as String?;
    final scheduled = doc['ScheduledDeliveryDate'] as String?;
    if (cityFrom != null && cityFrom.isNotEmpty) {
      steps.add('Відправлено: $cityFrom');
    }
    if (cityTo != null && cityTo.isNotEmpty) {
      steps.add('Отримувач: $cityTo');
    }
    if (scheduled != null && scheduled.isNotEmpty) {
      steps.add('Очікуваний день: $scheduled');
    }
    steps.add('Статус: $status');

    return TrackingResult(status: status, steps: steps);
  }

  /// Ukrposhta Tracking API
  static Future<TrackingResult> trackUkrposhta({
    required String token,
    required String trackingNumber,
  }) async {
    if (token.isEmpty) {
      throw Exception('Токен Укрпошти не налаштований. '
          'Будь ласка, додайте його в Налаштування → API інтеграції.');
    }

    final response = await http.get(
      Uri.parse(
          'https://www.ukrposhta.ua/status-tracking/0.0.1/statuses?barcode=$trackingNumber'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'Помилка з\'єднання з Укрпоштою (${response.statusCode})');
    }

    final list = jsonDecode(response.body) as List<dynamic>? ?? [];
    if (list.isEmpty) {
      throw Exception('Посилку з номером "$trackingNumber" не знайдено.');
    }

    final steps = list.map((item) {
      final s = item as Map<String, dynamic>;
      final name = s['name'] ?? s['eventName'] ?? '';
      final date = s['date'] ?? s['eventTime'] ?? '';
      return '$date — $name'.trim();
    }).toList();

    final lastStatus = steps.isNotEmpty ? steps.last : 'Невідомо';

    return TrackingResult(status: lastStatus, steps: steps);
  }
}
