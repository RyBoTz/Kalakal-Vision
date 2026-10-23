import 'package:flutter/material.dart';
import '../models/scrap_item.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Dashboard Summary Metrics
  int _itemsScannedToday = 18;
  int get itemsScannedToday => _itemsScannedToday;

  double _estimatedTotalValue = 1240.00;
  double get estimatedTotalValue => _estimatedTotalValue;

  double _gradeAPercentage = 56.0;
  double get gradeAPercentage => _gradeAPercentage;

  int _batchesReadyToSell = 3;
  int get batchesReadyToSell => _batchesReadyToSell;

  // Inventory Batches
  final List<InventoryBatch> _inventoryBatches = [
    InventoryBatch(
      id: 'b-01',
      category: MaterialCategory.corrugatedCardboard,
      grade: QualityGrade.gradeB,
      weightKg: 24.0,
      estimatedValue: 96.0,
      recommendation: 'Sell now — Cardboard Grade B',
      reason: 'Price is expected to drop about 6% over the next 10 days.',
      priceTrendPercent: -6.0,
      isLiquidationUrgent: true,
    ),
    InventoryBatch(
      id: 'b-02',
      category: MaterialCategory.aluminumCans,
      grade: QualityGrade.gradeA,
      weightKg: 15.0,
      estimatedValue: 975.0,
      recommendation: 'Sell now — Aluminum Cans',
      reason: 'Local smelting centers showing peak buying demand this week (+8%).',
      priceTrendPercent: 8.5,
      isLiquidationUrgent: true,
    ),
    InventoryBatch(
      id: 'b-03',
      category: MaterialCategory.plasticPet,
      grade: QualityGrade.gradeA,
      weightKg: 42.0,
      estimatedValue: 504.0,
      recommendation: 'Hold 5-7 days — PET Clear Bottles',
      reason: 'Recycling plant maintenance ending soon. Projected +12% price surge.',
      priceTrendPercent: 12.0,
      isLiquidationUrgent: false,
    ),
    InventoryBatch(
      id: 'b-04',
      category: MaterialCategory.scrapCopper,
      grade: QualityGrade.gradeA,
      weightKg: 8.5,
      estimatedValue: 2890.0,
      recommendation: 'Hold 7 days — Copper Wire',
      reason: 'Smelting supply deficit causing steady price appreciation (+5%).',
      priceTrendPercent: 5.2,
      isLiquidationUrgent: false,
    ),
  ];

  List<InventoryBatch> get inventoryBatches => _inventoryBatches;

  // Recent Scans
  final List<ScrapScanResult> _recentScans = [
    ScrapScanResult(
      id: 's-101',
      category: MaterialCategory.plasticPet,
      grade: QualityGrade.gradeA,
      confidence: 0.984,
      weightKg: 3.5,
      pricePerKg: 12.00,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      actionRecommendation: 'SELL NOW (Peak Demand)',
      isSellNow: true,
    ),
    ScrapScanResult(
      id: 's-102',
      category: MaterialCategory.aluminumCans,
      grade: QualityGrade.gradeA,
      confidence: 0.991,
      weightKg: 1.2,
      pricePerKg: 65.00,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      actionRecommendation: 'SELL NOW (High Buying Rate)',
      isSellNow: true,
    ),
    ScrapScanResult(
      id: 's-103',
      category: MaterialCategory.corrugatedCardboard,
      grade: QualityGrade.gradeB,
      confidence: 0.945,
      weightKg: 12.0,
      pricePerKg: 4.00,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      actionRecommendation: 'SELL IMMEDIATELY (Declining Rate)',
      isSellNow: true,
    ),
  ];

  List<ScrapScanResult> get recentScans => _recentScans;

  void addScanResult(ScrapScanResult scan) {
    _recentScans.insert(0, scan);
    _itemsScannedToday += 1;
    _estimatedTotalValue += scan.totalEstimatedValue;
    notifyListeners();
  }

  // Price Trend Data
  final Map<MaterialCategory, PriceTrendData> _priceTrends = {
    MaterialCategory.plasticPet: PriceTrendData(
      category: MaterialCategory.plasticPet,
      currentPricePerKg: 12.00,
      dayChangePercent: 2.5,
      outlook7Days: 'Bullish (+8%)',
      historical7Days: [11.2, 11.4, 11.5, 11.8, 11.7, 11.9, 12.0],
      projected7Days: [12.0, 12.2, 12.4, 12.6, 12.8, 12.9, 13.0],
    ),
    MaterialCategory.aluminumCans: PriceTrendData(
      category: MaterialCategory.aluminumCans,
      currentPricePerKg: 65.00,
      dayChangePercent: 4.1,
      outlook7Days: 'Peak Demand (+10%)',
      historical7Days: [58.0, 59.5, 61.0, 62.0, 63.5, 64.0, 65.0],
      projected7Days: [65.0, 66.5, 68.0, 69.0, 70.0, 71.5, 72.0],
    ),
    MaterialCategory.corrugatedCardboard: PriceTrendData(
      category: MaterialCategory.corrugatedCardboard,
      currentPricePerKg: 4.00,
      dayChangePercent: -5.0,
      outlook7Days: 'Bearish (-6%)',
      historical7Days: [4.8, 4.7, 4.5, 4.4, 4.2, 4.1, 4.0],
      projected7Days: [4.0, 3.9, 3.8, 3.75, 3.7, 3.65, 3.6],
    ),
    MaterialCategory.scrapCopper: PriceTrendData(
      category: MaterialCategory.scrapCopper,
      currentPricePerKg: 340.00,
      dayChangePercent: 1.8,
      outlook7Days: 'Steady Gain (+5%)',
      historical7Days: [325.0, 328.0, 330.0, 332.0, 335.0, 338.0, 340.0],
      projected7Days: [340.0, 343.0, 345.0, 348.0, 350.0, 354.0, 357.0],
    ),
  };

  Map<MaterialCategory, PriceTrendData> get priceTrends => _priceTrends;
}
