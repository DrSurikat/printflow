import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'models/app_settings.dart';
import 'models/client.dart';
import 'models/delivery_tracking.dart';
import 'models/material_item.dart';
import 'models/order.dart';
import 'models/order_item.dart';
import 'models/print_model.dart';
import 'providers/client_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/material_provider.dart';
import 'providers/order_provider.dart';
import 'providers/print_model_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await initializeDateFormatting('uk_UA', null);

  // Register adapters
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(OrderStatusAdapter());
  Hive.registerAdapter(MaterialCategoryAdapter());
  Hive.registerAdapter(MaterialItemAdapter());
  Hive.registerAdapter(ModelFileTypeAdapter());
  Hive.registerAdapter(PrintModelAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(DeliveryCarrierAdapter());
  Hive.registerAdapter(DeliveryTrackingAdapter());

  // Open boxes
  await Hive.openBox<Order>('orders');
  await Hive.openBox<Client>('clients');
  await Hive.openBox<MaterialItem>('materials');
  await Hive.openBox<PrintModel>('print_models');
  await Hive.openBox<AppSettings>('settings');
  await Hive.openBox<DeliveryTracking>('deliveries');

  runApp(const PrintFlowApp());
}

class PrintFlowApp extends StatefulWidget {
  const PrintFlowApp({super.key});

  @override
  State<PrintFlowApp> createState() => _PrintFlowAppState();
}

class _PrintFlowAppState extends State<PrintFlowApp> {
  @override
  void initState() {
    super.initState();
    // Check for updates 3 seconds after launch
    Future.delayed(const Duration(seconds: 3), _checkUpdate);
  }

  Future<void> _checkUpdate() async {
    final info = await UpdateService.check();
    if (info == null || !info.hasUpdate) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Доступна нова версія ${info.latestVersion} ✨'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Завантажити',
          onPressed: () async {
            // Navigate to settings where user can download
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => PrintModelProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
      ],
      child: MaterialApp(
        title: 'PrintFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('uk', 'UA'),
          Locale('en', 'US'),
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
