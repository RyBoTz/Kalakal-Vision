enum MaterialCategory {
  plastic,
  paper,
  metal,
}

extension MaterialCategoryExtension on MaterialCategory {
  String get displayName {
    switch (this) {
      case MaterialCategory.plastic:
        return 'Plastic (Bottles & Containers)';
      case MaterialCategory.paper:
        return 'Paper & Cardboard';
      case MaterialCategory.metal:
        return 'Metal (Cans & Scrap Metals)';
    }
  }

  String get shortCode {
    switch (this) {
      case MaterialCategory.plastic:
        return 'PLASTIC';
      case MaterialCategory.paper:
        return 'PAPER';
      case MaterialCategory.metal:
        return 'METAL';
    }
  }
}

enum QualityGrade { gradeA, gradeB, gradeC }

extension QualityGradeExtension on QualityGrade {
  String get nameLabel {
    switch (this) {
      case QualityGrade.gradeA:
        return 'GRADE A (High Purity)';
      case QualityGrade.gradeB:
        return 'GRADE B (Standard)';
      case QualityGrade.gradeC:
        return 'GRADE C (Contaminated/Mixed)';
    }
  }
}

class ScrapScanResult {
  final String id;
  final MaterialCategory category;
  final QualityGrade grade;
  final double confidence;
  final double weightKg;
  final double pricePerKg;
  final DateTime timestamp;
  final String actionRecommendation; // e.g. "SELL NOW (Peak Demand)" or "HOLD (5-7 days)"
  final bool isSellNow;
  final String? imagePath;

  ScrapScanResult({
    required this.id,
    required this.category,
    required this.grade,
    required this.confidence,
    required this.weightKg,
    required this.pricePerKg,
    required this.timestamp,
    required this.actionRecommendation,
    required this.isSellNow,
    this.imagePath,
  });

  double get totalEstimatedValue => weightKg * pricePerKg;
}

class InventoryBatch {
  final String id;
  final MaterialCategory category;
  final QualityGrade grade;
  final double weightKg;
  final double estimatedValue;
  final String recommendation;
  final String reason;
  final double priceTrendPercent;
  final bool isLiquidationUrgent;

  InventoryBatch({
    required this.id,
    required this.category,
    required this.grade,
    required this.weightKg,
    required this.estimatedValue,
    required this.recommendation,
    required this.reason,
    required this.priceTrendPercent,
    required this.isLiquidationUrgent,
  });
}

class PriceTrendData {
  final MaterialCategory category;
  final double currentPricePerKg;
  final double dayChangePercent;
  final String outlook7Days;
  final List<double> historical7Days;
  final List<double> projected7Days;

  PriceTrendData({
    required this.category,
    required this.currentPricePerKg,
    required this.dayChangePercent,
    required this.outlook7Days,
    required this.historical7Days,
    required this.projected7Days,
  });
}
