import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/print_model.dart';

class PrintModelProvider extends ChangeNotifier {
  final Box<PrintModel> _box = Hive.box<PrintModel>('print_models');
  final _uuid = const Uuid();

  String _searchQuery = '';
  ModelFileType? _filterType;

  List<PrintModel> get all =>
      _box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<PrintModel> get filtered {
    var list = all;
    if (_filterType != null) {
      list = list.where((m) => m.fileType == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((m) {
        return m.name.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q) ||
            (m.clientName?.toLowerCase().contains(q) ?? false) ||
            (m.tags?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    return list;
  }

  String get searchQuery => _searchQuery;
  ModelFileType? get filterType => _filterType;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterType(ModelFileType? t) {
    _filterType = t;
    notifyListeners();
  }

  int get totalCount => _box.length;
  int get totalPrints => all.fold(0, (sum, m) => sum + m.printCount);

  Future<PrintModel> addModel({
    required String name,
    String description = '',
    required ModelFileType fileType,
    String? clientId,
    String? clientName,
    double? printTimeHours,
    double? weightGrams,
    String? filePath,
    String? tags,
    String? notes,
  }) async {
    final model = PrintModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      fileType: fileType,
      createdAt: DateTime.now(),
      clientId: clientId,
      clientName: clientName,
      printTimeHours: printTimeHours,
      weightGrams: weightGrams,
      filePath: filePath,
      tags: tags,
      notes: notes,
    );
    await _box.put(model.id, model);
    notifyListeners();
    return model;
  }

  Future<void> updateModel(PrintModel model) async {
    await _box.put(model.id, model);
    notifyListeners();
  }

  Future<void> incrementPrintCount(String id) async {
    final model = _box.get(id);
    if (model == null) return;
    await _box.put(id, model.copyWith(printCount: model.printCount + 1));
    notifyListeners();
  }

  Future<void> deleteModel(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  PrintModel? getById(String id) => _box.get(id);

  List<PrintModel> getByClient(String clientId) =>
      all.where((m) => m.clientId == clientId).toList();
}
