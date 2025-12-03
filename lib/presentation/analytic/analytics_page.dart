import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../themes/category_colors.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    // SORTED DATA
    final monthly = Map.fromEntries(
      tx.groupByMonth().entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    final weekly = Map.fromEntries(
      tx.groupByWeek().entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    final categories = tx.groupByCategory();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        title: const Text(
          "Analitik",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Ringkasan Bulanan"),
              _buildMonthlyBarChart(monthly, settings),

              const SizedBox(height: 20),
              _sectionTitle("Ringkasan Mingguan"),
              _buildWeeklyLineChart(weekly, settings),

              const SizedBox(height: 20),
              _sectionTitle("Pengeluaran per Kategori"),
              _buildCategoryPieChart(categories, settings),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // SECTION TITLE
  // ============================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    );
  }

  // ============================
  // MONTHLY BAR CHART
  // ============================
  Widget _buildMonthlyBarChart(
      Map<String, double> data, SettingsProvider settings) {
    if (data.isEmpty) return _emptyCard();

    final bars = <BarChartGroupData>[];
    var i = 0;

    // maxY for scaling
    final maxY = data.values.isEmpty
        ? 10.0
        : data.values.reduce(max) * 1.25;

    for (final e in data.entries) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: e.value,
              color: Colors.blueAccent,
              width: 14,
              borderRadius: BorderRadius.circular(6),
            )
          ],
        ),
      );
      i++;
    }

    return _card(
      height: 260,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (v, meta) {
                  if (v == 0) return const SizedBox();
                  return Text(
                    "${settings.currencySymbol}${v.toInt()}",
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, meta) {
                  final index = v.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Transform.rotate(
                    angle: -0.45,
                    child: Text(
                      data.keys.elementAt(index),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: bars,
        ),
      ),
    );
  }

  // ============================
  // WEEKLY LINE CHART
  // ============================
  Widget _buildWeeklyLineChart(
      Map<String, double> data, SettingsProvider settings) {
    if (data.isEmpty) return _emptyCard();

    final spots = <FlSpot>[];
    var index = 0;

    for (final e in data.entries) {
      spots.add(FlSpot(index.toDouble(), e.value));
      index++;
    }

    final maxY = data.values.reduce(max) * 1.25;

    return _card(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, meta) {
                  if (v == 0) return const SizedBox();
                  return Text(
                    "${settings.currencySymbol}${v.toInt()}",
                    style: const TextStyle(fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, meta) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  return Transform.rotate(
                    angle: -0.45,
                    child: Text(
                      data.keys.elementAt(idx),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: spots,
              color: Colors.deepPurple,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // CATEGORY PIE CHART
  // ============================
  Widget _buildCategoryPieChart(
      Map<String, double> data, SettingsProvider settings) {
    if (data.isEmpty) return _emptyCard();

    final items = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    // Avoid divide-by-zero
    if (total == 0) return _emptyCard();

    return _card(
      height: 280,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          sections: [
            for (var i = 0; i < items.length; i++)
              PieChartSectionData(
                value: items[i].value,
                color: CategoryColors.getColor(items[i].key),
                radius: 60,
                title:
                    "${((items[i].value / total) * 100).toStringAsFixed(1)}%",
                titleStyle: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================
  // CARD WRAPPER
  // ============================
  Widget _card({required double height, required Widget child}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  // ============================
  // EMPTY STATE
  // ============================
  Widget _emptyCard() {
    return Container(
      height: 130,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        "Belum ada data",
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
