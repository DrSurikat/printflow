import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  final Box<Order> _box = Hive.box<Order>('orders');
  final _uuid = const Uuid();

  String _searchQuery = '';
  OrderStatus? _filterStatus;
  bool _filterOverdue = false;

  List<Order> get all => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Order> get filtered {
    var list = all;
    if (_filterStatus != null) {
      list = list.where((o) => o.status == _filterStatus).toList();
    }
    if (_filterOverdue) {
      list = list.where((o) => o.isOverdue).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((o) {
        return o.number.toLowerCase().contains(q) ||
            o.clientName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  String get searchQuery => _searchQuery;
  OrderStatus? get filterStatus => _filterStatus;
  bool get filterOverdue => _filterOverdue;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterStatus(OrderStatus? s) {
    _filterStatus = s;
    notifyListeners();
  }

  void toggleOverdueFilter() {
    _filterOverdue = !_filterOverdue;
    notifyListeners();
  }

  // Stats
  int get totalCount => _box.length;

  int countByStatus(OrderStatus s) =>
      all.where((o) => o.status == s).length;

  int get overdueCount => all.where((o) => o.isOverdue).length;

  double get totalRevenue =>
      all.where((o) => o.status == OrderStatus.completed).fold(0, (s, o) => s + o.total);

  double get pendingRevenue => all
      .where((o) =>
          o.status != OrderStatus.completed &&
          o.status != OrderStatus.cancelled)
      .fold(0, (s, o) => s + o.total);

  String _generateNumber() {
    final now = DateTime.now();
    final existing = all.where((o) => o.createdAt.year == now.year).length + 1;
    return 'ORD-${now.year}-${existing.toString().padLeft(3, '0')}';
  }

  Future<Order> addOrder({
    required String clientId,
    required String clientName,
    DateTime? deadline,
    required List<OrderItem> items,
    String? notes,
    double? discount,
    String? paymentMethod,
  }) async {
    final order = Order(
      id: _uuid.v4(),
      clientId: clientId,
      clientName: clientName,
      createdAt: DateTime.now(),
      deadline: deadline,
      items: items,
      notes: notes,
      number: _generateNumber(),
      discount: discount,
      paymentMethod: paymentMethod,
    );
    await _box.put(order.id, order);
    notifyListeners();
    return order;
  }

  Future<void> updateOrder(Order order) async {
    await _box.put(order.id, order);
    notifyListeners();
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    final order = _box.get(id);
    if (order == null) return;
    await _box.put(
        id,
        order.copyWith(
          status: status,
          isPaid: status == OrderStatus.completed ? true : order.isPaid,
        ));
    notifyListeners();
  }

  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Order? getById(String id) => _box.get(id);

  List<Order> getByClient(String clientId) =>
      all.where((o) => o.clientId == clientId).toList();
}
