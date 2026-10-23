import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scrap_item.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class WhatToDoScreen extends StatefulWidget {
  final AppState appState;

  const WhatToDoScreen({super.key, required this.appState});

  @override
  State<WhatToDoScreen> createState() => _WhatToDoScreenState();
}

class _WhatToDoScreenState extends State<WhatToDoScreen> {
  int _selectedFilter = 0; // 0: All, 1: Fast Liquidation, 2: Hold Reserve

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allBatches = widget.appState.inventoryBatches;
    final urgentBatches = allBatches.where((b) => b.isLiquidationUrgent).toList();
    final holdBatches = allBatches.where((b) => !b.isLiquidationUrgent).toList();

    List<InventoryBatch> displayedBatches;
    if (_selectedFilter == 1) {
      displayedBatches = urgentBatches;
    } else if (_selectedFilter == 2) {
      displayedBatches = holdBatches;
    } else {
      displayedBatches = allBatches;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryAlert,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Strategic Advisory",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "What to Do With Today's Stock",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Suggestions for today's stock based on material grade and live local market trends.",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Advisory Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.tertiaryAlert.withAlpha(40)
                            : AppColors.alertBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tertiaryAlert.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_down_rounded,
                                color: AppColors.alertText,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "FAST LIQUIDATION",
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.alertText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${urgentBatches.length} Batches",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            "Avoid ₱42+ value slip",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withAlpha(40)
                            : AppColors.primaryContainer.withAlpha(120),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "UPSIDE RESERVE",
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "+₱128 Potential",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            "Holding 5-7 days",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Tabs Row
              Row(
                children: [
                  _buildFilterChip(0, "All (${allBatches.length})", isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, "Sell Now (${urgentBatches.length})", isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, "Hold Reserve (${holdBatches.length})", isDark),
                ],
              ),
              const SizedBox(height: 16),

              // Inventory Batches List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedBatches.length,
                itemBuilder: (context, index) {
                  final batch = displayedBatches[index];
                  return _buildBatchCard(context, batch, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, bool isDark) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = index);
      },
      selectedColor: AppColors.primary,
      labelStyle: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      backgroundColor: isDark
          ? AppColors.surfaceContainerHighDark
          : AppColors.surfaceContainerHighLight,
    );
  }

  Widget _buildBatchCard(BuildContext context, InventoryBatch batch, bool isDark) {
    final isUrgent = batch.isLiquidationUrgent;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
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
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(batch.category),
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    batch.category.displayName,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.alertBg
                      : AppColors.primaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${batch.priceTrendPercent > 0 ? '+' : ''}${batch.priceTrendPercent}% (10d)",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUrgent ? AppColors.alertText : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            batch.recommendation,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isUrgent
                  ? (isDark ? Colors.redAccent : AppColors.alertText)
                  : AppColors.success,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            batch.reason,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Yard Stock: ${batch.weightKg} kg",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                "Est. ₱${batch.estimatedValue.toStringAsFixed(2)}",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Action recorded for ${batch.category.displayName}"),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUrgent ? AppColors.primary : Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isUrgent ? "SELL NOW TO BUYER" : "SCHEDULE HOLD ALERTS",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
