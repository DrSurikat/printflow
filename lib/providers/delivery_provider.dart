import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/delivery_tracking.dart';
import '../services/delivery_service.dart';

class DeliveryProvider extends ChangeNotifier {
  static const _boxName = 'deliveries';

  final Box<DeliveryTracking> _box = Hive.box<DeliveryTracking>(_boxName);
  final _uuid = const Uuid();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DeliveryTracking> getByOrder(String orderId) =>
      _box.values.where((t) => t.orderId == orderId).toList();

  DeliveryTracking? getLatestByOrder(String orderId) {
    final list = getByOrder(orderId);
    if (list.isEmpty) return null;
    list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return list.first;
  }

  Future<DeliveryTracking?> track({
    required String orderId,
    required String orderNumber,
    required String trackingNumber,
    required DeliveryCarrier carrier,
    required String apiKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      TrackingResult result;
      switch (carrier) {
        case DeliveryCarrier.novaPoshta:
          result = await DeliveryService.trackNovaPoshta(
            apiKey: apiKey,
            trackingNumber: trackingNumber,
          );
        case DeliveryCarrier.ukrposhta:
          result = await DeliveryService.trackUkrposhta(
            token: apiKey,
            trackingNumber: trackingNumber,
          );
      }

      // Update or create tracking record
      final existing = _box.values
          .where(
              (t) => t.orderId == orderId && t.trackingNumber == trackingNumber)
          .firstOrNull;

      if (existing != null) {
        existing.lastStatus = result.status;
        existing.lastUpdated = DateTime.now();
        existing.history = result.steps;
        await existing.save();
        _isLoading = false;
        notifyListeners();
        return existing;
      } else {
        final tracking = DeliveryTracking(
          id: _uuid.v4(),
          orderId: orderId,
          orderNumber: orderNumber,
          carrier: carrier,
          trackingNumber: trackingNumber,
          lastStatus: result.status,
          lastUpdated: DateTime.now(),
          history: result.steps,
        );
        await _box.put(tracking.id, tracking);
        _isLoading = false;
        notifyListeners();
        return tracking;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
