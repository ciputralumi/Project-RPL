import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// MODELS
import 'data/models/transaction_model.dart';
import 'data/models/budget_model.dart';
import 'data/models/account_model.dart';
import 'data/models/saving_goal_model.dart';
import 'data/models/saving_log_model.dart';

// PROVIDERS
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/account_provider.dart';
import 'providers/saving_goal_provider.dart';
import 'providers/saving_log_provider.dart';

// UI
import 'presentation/auth/login_page.dart';
import 'presentation/main_navigation.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<SavingLogModel>('saving_logs_box');

  // -------------------------------
  // REGISTER ADAPTERS (WAJIB)
  // -------------------------------
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(SavingGoalModelAdapter());
  Hive.registerAdapter(SavingLogModelAdapter());
  Hive.registerAdapter(SavingLogModelAdapter());


  // -------------------------------
  // OPEN BOXES
  // -------------------------------
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox('settings');
  await Hive.openBox<BudgetModel>('budgets_box');
  await Hive.openBox<AccountModel>('accounts_box');
  await Hive.openBox<SavingGoalModel>('saving_goals_box');
  await Hive.openBox<SavingLogModel>('saving_logs_box');  // ⭐ WAJIB ada
  await Hive.openBox('user_box');

  // -------------------------------
  // MULTIPROVIDER
  // -------------------------------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..init()),
        ChangeNotifierProvider(create: (_) => SavingGoalProvider()..init()),
        

        // ⭐ inilah yang kemarin bikin error — sekarang kita tambahkan
        ChangeNotifierProvider(create: (_) => SavingLogProvider()..init()),
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
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatelessWidget {
  const SplashRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      return const MainNavigation();
    } else {
      return const LoginPage();
    }
  }
}
