import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 8)
class AppSettings extends HiveObject {
  // --- Delivery API keys ---
  @HiveField(0)
  String novaPoshtaApiKey;

  @HiveField(1)
  String ukrposhtaToken;

  // --- Sender info for invoices ---
  @HiveField(2)
  String senderName;

  @HiveField(3)
  String senderAddress;

  @HiveField(4)
  String senderPhone;

  @HiveField(5)
  String senderIpn; // Individual Tax Number (ІПН)

  @HiveField(6)
  String invoiceFooterText; // e.g. bank account details

  @HiveField(7)
  String invoicePrefix; // e.g. "РФ" → invoice numbers like РФ-001

  AppSettings({
    this.novaPoshtaApiKey = '',
    this.ukrposhtaToken = '',
    this.senderName = '',
    this.senderAddress = '',
    this.senderPhone = '',
    this.senderIpn = '',
    this.invoiceFooterText = '',
    this.invoicePrefix = 'РФ',
  });

  static AppSettings get defaults => AppSettings();
}
