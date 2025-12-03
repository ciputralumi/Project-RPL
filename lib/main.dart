import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/models/transaction_model.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'presentation/main_navigation.dart';
import 'themes/app_theme.dart';
import 'providers/budget_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('settings'); // wajib untuk SettingsProvider

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Tracker',

      // Pakai theme custom kita
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(), // nanti kalau mau bikin dark mode ganti sini
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const MainNavigation(),
    );
  }
}
