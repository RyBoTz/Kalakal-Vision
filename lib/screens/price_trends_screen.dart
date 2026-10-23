import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scrap_item.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PriceTrendsScreen extends StatefulWidget {
  final AppState appState;

  const PriceTrendsScreen({super.key, required this.appState});

  @override
  State<PriceTrendsScreen> createState() => _PriceTrendsScreenState();
}

class _PriceTrendsScreenState extends State<PriceTrendsScreen> {
  MaterialCategory _selectedCategory = MaterialCategory.plasticPet;
  int _selectedHorizonDays = 7; // 7, 14, 30

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendData = widget.appState.priceTrends[_selectedCategory]!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "LIVE RATES & FORECAST",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Market Intelligence",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Where local Philippine junkshop recyclable prices are headed over the next 7 to 30 days.",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Time Horizon Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "7-Day Price Outlook",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Row(
                    children: [7, 14, 30].map((days) {
                      final isSelected = _selectedHorizonDays == days;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () => setState(() => _selectedHorizonDays = days),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.surfaceContainerHighDark
                                      : AppColors.surfaceContainerHighLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${days}D",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Material Category Chips Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.appState.priceTrends.keys.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat.displayName),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                        backgroundColor: isDark
                            ? AppColors.surfaceContainerHighDark
                            : AppColors.surfaceContainerHighLight,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Chart Container
              Container(
                height: 260,
                padding: const EdgeInsets.fromLTRB(16, 20, 20, 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price per kg (₱)",
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            _buildLegendItem("Historical", AppColors.primary, false),
                            const SizedBox(width: 12),
                            _buildLegendItem("7D Forecast", AppColors.success, true),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        _buildLineChartData(trendData, isDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Market Insight Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withAlpha(30)
                      : AppColors.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Market Note",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "High demand for aluminum cans & scrap copper at local smelting centers this week. Recommended to offload bulk inventory before Friday.",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Live Junkshop Buying Rates Table
              Text(
                "Current Local Junkshop Rates",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: widget.appState.priceTrends.values.map((trend) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.outlineDark
                            : AppColors.outlineLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(trend.category),
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trend.category.displayName,
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  trend.outlook7Days,
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 11,
                                    color: trend.dayChangePercent > 0
                                        ? AppColors.success
                                        : AppColors.alertText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₱${trend.currentPricePerKg.toStringAsFixed(2)} / kg",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              "${trend.dayChangePercent > 0 ? '+' : ''}${trend.dayChangePercent}% today",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: trend.dayChangePercent > 0
                                    ? AppColors.success
                                    : AppColors.alertText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(PriceTrendData trend, bool isDark) {
    final spots = <FlSpot>[];
    for (int i = 0; i < trend.historical7Days.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend.historical7Days[i]));
    }

    final projSpots = <FlSpot>[];
    final lastHist = trend.historical7Days.last;
    projSpots.add(FlSpot((trend.historical7Days.length - 1).toDouble(), lastHist));
    for (int i = 1; i < trend.projected7Days.length; i++) {
      projSpots.add(
        FlSpot((trend.historical7Days.length - 1 + i).toDouble(), trend.projected7Days[i]),
      );
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, meta) {
              if (val == 0) return const Text('-7D', style: TextStyle(fontSize: 10));
              if (val == 6) return const Text('Today', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
              if (val == 12) return const Text('+7D', style: TextStyle(fontSize: 10));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
        LineChartBarData(
          spots: projSpots,
          isCurved: true,
          color: AppColors.success,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.plasticPet:
        return Icons.local_drink_outlined;
      case MaterialCategory.aluminumCans:
        return Icons.view_in_ar_outlined;
      case MaterialCategory.corrugatedCardboard:
        return Icons.inventory_2_outlined;
      case MaterialCategory.scrapCopper:
        return Icons.cable_outlined;
      case MaterialCategory.scrapIron:
        return Icons.hardware_outlined;
    }
  }
}
