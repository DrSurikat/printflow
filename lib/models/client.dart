import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String email;

  @HiveField(4)
  late String company;

  @HiveField(5)
  late String address;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? telegram; // username, e.g. "username" or "+380XXXXXXXXX"

  @HiveField(9)
  String? viber; // phone number, e.g. "+380XXXXXXXXX"

  @HiveField(10)
  String? instagram; // username, e.g. "username"

  Client({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.company = '',
    this.address = '',
    required this.createdAt,
    this.notes,
    this.telegram,
    this.viber,
    this.instagram,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? company,
    String? address,
    DateTime? createdAt,
    String? notes,
    String? telegram,
    String? viber,
    String? instagram,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      telegram: telegram ?? this.telegram,
      viber: viber ?? this.viber,
      instagram: instagram ?? this.instagram,
    );
  }
}
