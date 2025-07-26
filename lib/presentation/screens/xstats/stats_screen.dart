import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_cubit.dart';
import 'package:alfa_scout/presentation/blocs/pub/pub_state.dart';
import 'package:alfa_scout/domain/models/pub_auto.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _formatNumber(double value) {
    if (value >= 1000) {
      final result = value / 1000;
      return result % 1 == 0 ? '${result.toInt()}k €' : '${result.toStringAsFixed(1)}k €';
    }
    return '${value.toInt()} €';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<PubCubit, PubState>(
          builder: (context, state) {
            if (state.status != PubStatus.success) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = _calculateAveragePrices(state.pubs);
            if (data.isEmpty) {
              return const Center(child: Text('Nessun dato disponibile'));
            }

            final categories = data.keys.toList();
            final values = data.values.toList();
            final maxY = values.reduce((a, b) => a > b ? a : b) + 1000;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prezzo medio per modello',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: categories.length * 60,
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color.fromRGBO(158, 158, 158, 0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        groupsSpace: 16,
                        barGroups: List.generate(categories.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: values[i],
                                width: 30,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF630101), Color(0xFFE72121)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) => Text(
                                _formatNumber(value),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                return index < categories.length
                                    ? Transform.rotate(
                                        angle: -1.2,
                                        child: Text(
                                          categories[index],
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipMargin: 8,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${categories[group.x]}: ${_formatNumber(rod.toY)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, double> _calculateAveragePrices(List<Pub> pubs) {
    final Map<String, List<double>> grouped = {};

    for (final pub in pubs) {
      final model = pub.model;
      final price = pub.price.toDouble();
      grouped.putIfAbsent(model, () => []).add(price);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: (entry.value.reduce((a, b) => a + b) / entry.value.length).roundToDouble()
    };
  }
}
