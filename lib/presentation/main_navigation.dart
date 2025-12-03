import 'package:flutter/material.dart';

import 'dashboard/dashboard_page.dart';
import 'transactions/transactions_page.dart';
import 'budget/budget_page.dart';
import 'analytic/analytics_page.dart';
import 'settings/settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    TransactionsPage(),
    BudgetPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false, // disable semua Hero untuk mencegah error
      child: Scaffold(
        body: _pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Transaksi",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: "Anggaran",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: "Analitik",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
