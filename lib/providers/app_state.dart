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
      category: MaterialCategory.metal,
      grade: QualityGrade.gradeA,
      weightKg: 18.5,
      estimatedValue: 1202.5,
      recommendation: 'Sell now — Metal (Cans & Scraps)',
      reason: 'Local junk shops and smelting centers showing peak buying demand this week (+8%).',
      priceTrendPercent: 8.5,
      isLiquidationUrgent: true,
    ),
    InventoryBatch(
      id: 'b-02',
      category: MaterialCategory.plastic,
      grade: QualityGrade.gradeA,
      weightKg: 42.0,
      estimatedValue: 588.0,
      recommendation: 'Hold 5-7 days — Plastic Bottles',
      reason: 'Recycling plant maintenance ending soon. Projected +12% price surge.',
      priceTrendPercent: 12.0,
      isLiquidationUrgent: false,
    ),
    InventoryBatch(
      id: 'b-03',
      category: MaterialCategory.paper,
      grade: QualityGrade.gradeB,
      weightKg: 30.0,
      estimatedValue: 135.0,
      recommendation: 'Sell immediately — Paper & Cardboard',
      reason: 'Rainy season humidity risk; price expected to drop about 5%.',
      priceTrendPercent: -5.0,
      isLiquidationUrgent: true,
    ),
  ];

  List<InventoryBatch> get inventoryBatches => _inventoryBatches;

  // Recent Scans
  final List<ScrapScanResult> _recentScans = [
    ScrapScanResult(
      id: 's-101',
      category: MaterialCategory.plastic,
      grade: QualityGrade.gradeA,
      confidence: 0.984,
      weightKg: 3.5,
      pricePerKg: 14.00,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      actionRecommendation: 'SELL NOW (High Recycler Demand)',
      isSellNow: true,
    ),
    ScrapScanResult(
      id: 's-102',
      category: MaterialCategory.metal,
      grade: QualityGrade.gradeA,
      confidence: 0.991,
      weightKg: 4.2,
      pricePerKg: 65.00,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      actionRecommendation: 'SELL NOW (Peak Buying Rate)',
      isSellNow: true,
    ),
    ScrapScanResult(
      id: 's-103',
      category: MaterialCategory.paper,
      grade: QualityGrade.gradeB,
      confidence: 0.945,
      weightKg: 12.0,
      pricePerKg: 4.50,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      actionRecommendation: 'SELL SOON (Keep Dry)',
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
    MaterialCategory.plastic: PriceTrendData(
      category: MaterialCategory.plastic,
      currentPricePerKg: 14.00,
      dayChangePercent: 2.5,
      outlook7Days: 'Bullish (+8%)',
      historical7Days: [12.5, 12.8, 13.0, 13.4, 13.6, 13.8, 14.0],
      projected7Days: [14.0, 14.2, 14.5, 14.8, 15.0, 15.1, 15.2],
    ),
    MaterialCategory.paper: PriceTrendData(
      category: MaterialCategory.paper,
      currentPricePerKg: 4.50,
      dayChangePercent: -2.0,
      outlook7Days: 'Slight Dip (-3%)',
      historical7Days: [5.0, 4.9, 4.8, 4.7, 4.6, 4.5, 4.5],
      projected7Days: [4.5, 4.4, 4.4, 4.35, 4.3, 4.3, 4.25],
    ),
    MaterialCategory.metal: PriceTrendData(
      category: MaterialCategory.metal,
      currentPricePerKg: 65.00,
      dayChangePercent: 4.1,
      outlook7Days: 'Peak Demand (+10%)',
      historical7Days: [58.0, 59.5, 61.0, 62.0, 63.5, 64.0, 65.0],
      projected7Days: [65.0, 66.5, 68.0, 69.0, 70.0, 71.5, 72.0],
    ),
  };

  Map<MaterialCategory, PriceTrendData> get priceTrends => _priceTrends;
}
