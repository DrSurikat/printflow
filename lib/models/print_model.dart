import 'package:hive/hive.dart';

part 'print_model.g.dart';

@HiveType(typeId: 6)
enum ModelFileType {
  @HiveField(0)
  stl,

  @HiveField(1)
  obj,

  @HiveField(2)
  step,

  @HiveField(3)
  other,
}

extension ModelFileTypeExtension on ModelFileType {
  String get label {
    switch (this) {
      case ModelFileType.stl:
        return 'STL';
      case ModelFileType.obj:
        return 'OBJ';
      case ModelFileType.step:
        return 'STEP';
      case ModelFileType.other:
        return 'Інше';
    }
  }
}

@HiveType(typeId: 7)
class PrintModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late ModelFileType fileType;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  String? clientId; // optional: linked to a client

  @HiveField(6)
  String? clientName;

  @HiveField(7)
  double? printTimeHours; // estimated print time

  @HiveField(8)
  double? weightGrams; // estimated material usage

  @HiveField(9)
  String? filePath; // local path to file

  @HiveField(10)
  String? tags; // comma-separated tags

  @HiveField(11)
  int printCount; // how many times this model was printed

  @HiveField(12)
  String? notes;

  PrintModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.fileType,
    required this.createdAt,
    this.clientId,
    this.clientName,
    this.printTimeHours,
    this.weightGrams,
    this.filePath,
    this.tags,
    this.printCount = 0,
    this.notes,
  });

  List<String> get tagList => tags == null || tags!.isEmpty
      ? []
      : tags!.split(',').map((t) => t.trim()).toList();

  PrintModel copyWith({
    String? id,
    String? name,
    String? description,
    ModelFileType? fileType,
    DateTime? createdAt,
    String? clientId,
    String? clientName,
    double? printTimeHours,
    double? weightGrams,
    String? filePath,
    String? tags,
    int? printCount,
    String? notes,
  }) {
    return PrintModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      printTimeHours: printTimeHours ?? this.printTimeHours,
      weightGrams: weightGrams ?? this.weightGrams,
      filePath: filePath ?? this.filePath,
      tags: tags ?? this.tags,
      printCount: printCount ?? this.printCount,
      notes: notes ?? this.notes,
    );
  }
}
