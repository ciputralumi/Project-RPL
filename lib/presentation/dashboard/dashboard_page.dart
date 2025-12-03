// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_page.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../transactions/add_transaction_modal.dart';
import '../transactions/transactions_list_page.dart';
import '../../themes/category_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int selectedPeriodIndex = 2; // Monthly
  final periods = ['Daily', 'Weekly', 'Monthly', 'Annual'];

  late final AnimationController _listAnimateController;
  late final AnimationController _donutController;

  @override
  void initState() {
    super.initState();

    _listAnimateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().setFilter(selectedPeriodIndex);
      _listAnimateController.forward();
      _donutController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimateController.dispose();
    _donutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final s = context.watch<SettingsProvider>();

    final income = tx.totalIncome;
    final expense = tx.totalExpense;
    final balance = tx.totalBalance;
    final transactions = tx.filteredTransactions;

    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      categoryTotals.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    }

    final totalForPie =
        categoryTotals.values.fold<double>(0, (a, b) => a + b);

    final segments = categoryTotals.entries
        .map((e) => _PieSegment(label: e.key, value: e.value))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F4CFF),
        child: const Icon(Icons.add, size: 28),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddTransactionModal(),
          );
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(balance, income, expense, s),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodChips(tx),
                    const SizedBox(height: 14),

                    _buildSmartSummary(context, tx, s),
                    const SizedBox(height: 14),

                    _buildSummaryCards(income, expense, s),
                    const SizedBox(height: 14),

                    AnimatedBuilder(
                      animation: _donutController,
                      builder: (_, __) => Opacity(
                        opacity: _donutController.value,
                        child: Transform.translate(
                          offset: Offset(
                              0, (1 - _donutController.value) * 10),
                          child: _buildAnalyticsCard(
                              segments, totalForPie, _donutController.value),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildGoalsCard(),
                    const SizedBox(height: 14),

                    _buildAccountsCard(),
                    const SizedBox(height: 14),

                    _buildTransactionsHeader(),
                    const SizedBox(height: 8),

                    _buildAnimatedPreview(transactions, s),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // HEADER
  // -------------------------------------------------------------------

  Widget _buildHeader(
      double balance, double income, double expense, SettingsProvider s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E7BFA), Color(0xFF2F4CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Saldo",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text("Belum ada notifikasi"),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "${s.currencySymbol}${_fmt(balance)}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _miniStatCard("Pemasukan", income, Colors.green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStatCard("Pengeluaran", expense, Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniStatCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            builder: (_, val, __) => Text(
              _fmt(val),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // PERIOD CHIPS
  // -------------------------------------------------------------------

  Widget _buildPeriodChips(TransactionProvider tx) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = selectedPeriodIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => selectedPeriodIndex = i);
              tx.setFilter(i);
              _donutController.forward(from: 0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFE8E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  periods[i],
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF2F4CFF)
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // SMART SUMMARY
  // -------------------------------------------------------------------

  Widget _buildSmartSummary(
      BuildContext context, TransactionProvider tx, SettingsProvider s) {
    final now = DateTime.now();

    final thisMonthTotal = tx.transactions
        .where((t) => t.date.month == now.month && !t.isIncome)
        .fold(0.0, (a, b) => a + b.amount);

    final lastMonth = now.month == 1 ? 12 : now.month - 1;

    final lastMonthTotal = tx.transactions
        .where((t) => t.date.month == lastMonth && !t.isIncome)
        .fold(0.0, (a, b) => a + b.amount);

    double percentChange = 0;
    if (lastMonthTotal > 0) {
      percentChange =
          ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100;
    }

    final Map<String, double> catTotals = {};
    tx.transactions
        .where((t) => t.date.month == now.month && !t.isIncome)
        .forEach((t) {
      catTotals.update(t.category, (v) => v + t.amount,
          ifAbsent: () => t.amount);
    });

    String topCategory = "-";
    double topValue = 0;

    if (catTotals.isNotEmpty) {
      final sorted = catTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      topCategory = sorted.first.key;
      topValue = sorted.first.value;
    }

    String insight;
    if (percentChange < 0) {
      insight =
          "Pengeluaran kamu turun ${percentChange.abs().toStringAsFixed(1)}% dari bulan lalu. Mantap cuy!";
    } else if (percentChange > 0) {
      insight =
          "Pengeluaran naik ${percentChange.toStringAsFixed(1)}% dibanding bulan lalu. Perlu lebih hati-hati nih.";
    } else {
      insight = "Pengeluaran kamu stabil dibanding bulan lalu.";
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Smart Summary",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            insight,
            style:
                const TextStyle(color: Colors.black87, height: 1.4),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  "Bulan Ini",
                  "${s.currencySymbol}${_fmt(thisMonthTotal)}",
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryTile(
                  "Bulan Lalu",
                  "${s.currencySymbol}${_fmt(lastMonthTotal)}",
                  Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (topCategory != "-")
            _summaryTile(
              "Kategori Tertinggi",
              "$topCategory (${s.currencySymbol}${_fmt(topValue)})",
              Colors.deepPurple,
            ),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // SUMMARY CARDS
  // -------------------------------------------------------------------

  Widget _buildSummaryCards(
      double income, double expense, SettingsProvider s) {
    return Row(
      children: [
        Expanded(
          child: _smallCard(
            "Income",
            "${s.currencySymbol}${_fmt(income)}",
            const Color(0xFF2ECC71),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _smallCard(
            "Expense",
            "${s.currencySymbol}${_fmt(expense)}",
            const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8)
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Balance",
                style: TextStyle(
                    color: Color(0xFF2F4CFF),
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _fmt(income - expense),
                style: const TextStyle(
                    color: Color(0xFF2F4CFF),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _smallCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, color: Colors.black54)),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ANALYTICS PIE + DONUT
  // -------------------------------------------------------------------

  Widget _buildAnalyticsCard(
      List<_PieSegment> segments, double total, double animValue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pengeluaran per Kategori",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (segments.isEmpty || total == 0)
            const _ShimmerPlaceholder(count: 3)
          else
            Row(
              children: [
                _AnimatedDonut(segments, total, animValue: animValue),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: segments.map((s) {
                      final c = CategoryColors.getColor(s.label);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(s.label,
                                    overflow: TextOverflow.ellipsis)),
                            Text(_short(s.value)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // GOALS & ACCOUNTS
  // -------------------------------------------------------------------

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Target Tabungan",
              style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text("Coming soon...", style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildAccountsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Akun Saya",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _accRow("Rekening Utama", "Bank Mandiri", "0"),
          const Divider(),
          _accRow("Tabungan", "Bank BCA", "0"),
        ],
      ),
    );
  }

  Widget _accRow(String title, String subtitle, String amount) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE8F0FF),
          child: const Icon(Icons.account_balance_wallet,
              color: Color(0xFF2F4CFF)),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black45)),
            ],
          ),
        ),

        Text(amount,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  // -------------------------------------------------------------------
  // TRANSACTIONS PREVIEW
  // -------------------------------------------------------------------

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Transactions",
            style: TextStyle(fontWeight: FontWeight.w700)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TransactionsListPage()),
            );
          },
          child: const Text("Lihat Semua"),
        ),
      ],
    );
  }

  Widget _buildAnimatedPreview(
      List<TransactionModel> items, SettingsProvider s) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: _ShimmerPlaceholder(count: 3),
      );
    }

    return Column(
      children: List.generate(
        items.length.clamp(0, 5),
        (index) {
          final tx = items[index];
          final delay = 80 * index;

          return AnimatedBuilder(
            animation: _listAnimateController,
            builder: (_, child) {
              final t = (_listAnimateController.value - (delay / 600))
                  .clamp(0.0, 1.0);

              final eased = Curves.easeOut.transform(t);

              return Opacity(
                opacity: eased,
                child: Transform.translate(
                  offset: Offset(0, (1 - eased) * 8),
                  child: child,
                ),
              );
            },
            child: _buildTransactionTile(tx, s),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx, SettingsProvider s) {
    final color = CategoryColors.getColor(tx.category);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
        ],
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.18),
            child: Icon(
              tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.note,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(tx.category,
                    style:
                        const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),

          Text(
            "${s.currencySymbol}${_fmt(tx.amount)}",
            style: TextStyle(
              color: tx.isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------

  String _fmt(double x) {
    if (x.isNaN || x.isInfinite) return "0";

    final s = x.abs().round().toString().split('').reversed.join();
    final parts = <String>[];

    for (int i = 0; i < s.length; i += 3) {
      parts.add(s.substring(i, min(i + 3, s.length)));
    }

    return parts
        .map((e) => e.split('').reversed.join())
        .toList()
        .reversed
        .join('.');
  }

  String _short(double v) {
    if (v >= 1000000) return "${(v / 1000000).toStringAsFixed(1)}M";
    if (v >= 1000) return "${(v / 1000).toStringAsFixed(1)}K";
    return v.toStringAsFixed(0);
  }
}

// -------------------------------------------------------------------
// PIE MODEL
// -------------------------------------------------------------------

class _PieSegment {
  final String label;
  final double value;

  _PieSegment({
    required this.label,
    required this.value,
  });
}

// -------------------------------------------------------------------
// DONUT ANIMATION
// -------------------------------------------------------------------

class _AnimatedDonut extends StatelessWidget {
  final List<_PieSegment> segments;
  final double total;
  final double animValue;

  const _AnimatedDonut(
    this.segments,
    this.total, {
    super.key,
    required this.animValue,
  });

  @override
  Widget build(BuildContext context) {
    final stops = <double>[];
    final colors = <Color>[];

    double acc = 0;

    for (final seg in segments) {
      final portion = (seg.value / total).clamp(0.0, 1.0) * animValue;
      acc += portion;
      stops.add(acc);
      colors.add(CategoryColors.getColor(seg.label));
    }

    if (stops.isNotEmpty) {
      stops.last = animValue.clamp(0.0, 1.0);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: colors.isEmpty
                  ? [Colors.grey.shade300]
                  : colors,
              stops: stops.isEmpty ? null : stops,
              startAngle: -pi / 2,
              endAngle: -pi / 2 + 2 * pi * animValue,
            ),
          ),
        ),

        // Inner white circle
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Text(
              "Total\n${_centerTotal()}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _centerTotal() {
    final t = segments.fold(0.0, (a, b) => a + b.value);
    if (t >= 1000000) return "${(t / 1000000).toStringAsFixed(1)}M";
    if (t >= 1000) return "${(t / 1000).toStringAsFixed(1)}K";
    return t.toStringAsFixed(0);
  }
}

// -------------------------------------------------------------------
// SHIMMER PLACEHOLDER (SKELETON LOADING)
// -------------------------------------------------------------------

class _ShimmerPlaceholder extends StatelessWidget {
  final int count;

  const _ShimmerPlaceholder({
    this.count = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final base = Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: const Alignment(-1, -0.3),
                end: const Alignment(1, 0.3),
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: base,
          ),
        );
      }),
    );
  }
}
