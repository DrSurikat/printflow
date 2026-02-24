import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/client.dart';

class ClientProvider extends ChangeNotifier {
  final Box<Client> _box = Hive.box<Client>('clients');
  final _uuid = const Uuid();

  String _searchQuery = '';

  List<Client> get all =>
      _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Client> get filtered {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.company.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  String get searchQuery => _searchQuery;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<Client> addClient({
    required String name,
    String phone = '',
    String email = '',
    String company = '',
    String address = '',
    String? notes,
    String? telegram,
    String? viber,
    String? instagram,
  }) async {
    final client = Client(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      company: company,
      address: address,
      createdAt: DateTime.now(),
      notes: notes,
      telegram: telegram,
      viber: viber,
      instagram: instagram,
    );
    await _box.put(client.id, client);
    notifyListeners();
    return client;
  }

  Future<void> updateClient(Client client) async {
    await _box.put(client.id, client);
    notifyListeners();
  }

  Future<void> deleteClient(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Client? getById(String id) => _box.get(id);

  int get totalCount => _box.length;
}
