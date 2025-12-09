import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/models/transaction_model.dart';
import 'data/models/budget_model.dart';
import 'data/models/account_model.dart'; 

import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/account_provider.dart';

import 'presentation/main_navigation.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  // REGISTER ADAPTERS
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(AccountModelAdapter()); // ← FIX TERPENTING

  // OPEN BOXES
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('settings');
  await Hive.openBox<BudgetModel>('budgets_box');
  await Hive.openBox<AccountModel>('accounts_box'); // ← FIX WAJIB

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..init()),
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigation(),
    );
  }
}
