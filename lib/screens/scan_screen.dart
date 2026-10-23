import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scrap_item.dart';
import '../providers/app_state.dart';
import '../services/yolo_api_service.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  final AppState appState;

  const ScanScreen({super.key, required this.appState});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  bool _isFlashOn = false;
  bool _isMacroOn = true;
  ScrapScanResult? _lastResult;
  Uint8List? _scannedImageBytes;
  String? _detectedLabel;
  final ImagePicker _picker = ImagePicker();

  MaterialCategory? _mapYoloClassToCategory(String yoloClass) {
    switch (yoloClass.toLowerCase()) {
      case 'plastic':
        return MaterialCategory.plastic;
      case 'metal':
        return MaterialCategory.metal;
      case 'paper':
        return MaterialCategory.paper;
      default:
        // Model detected other classes like Glass or general Waste not in target scope
        return null;
    }
  }

  Future<void> _processImageForYolo(Uint8List imageBytes, String filename) async {
    setState(() {
      _isScanning = true;
      _scannedImageBytes = imageBytes;
    });

    final response = await YoloApiService.predictImageBytes(
      imageBytes,
      filename: filename,
    );

    if (!mounted) return;

    if (response.success && response.topDetection != null) {
      final top = response.topDetection!;
      final cat = _mapYoloClassToCategory(top.className);

      if (cat == null) {
        setState(() {
          _isScanning = false;
          _detectedLabel = "Non-target item detected: ${top.className}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Detected ${top.className}. This app focuses on Plastic, Paper, and Metal."),
            backgroundColor: Colors.amber.shade800,
          ),
        );
        return;
      }

      final conf = top.confidence;
      final grade = conf > 0.7
          ? QualityGrade.gradeA
          : (conf > 0.4 ? QualityGrade.gradeB : QualityGrade.gradeC);

      double pricePerKg = 14.0;
      String action = 'SELL NOW (Peak Demand)';
      bool sellNow = true;

      if (cat == MaterialCategory.plastic) {
        pricePerKg = 14.0;
        action = 'SELL NOW (High Recycler Demand)';
      } else if (cat == MaterialCategory.metal) {
        pricePerKg = 65.0; // Encompasses cans, aluminum & scrap metals
        action = 'SELL NOW (Smelting & Junk Shop High Rate)';
      } else if (cat == MaterialCategory.paper) {
        pricePerKg = 4.5;
        action = 'KEEP DRY / SELL SOON';
      }

      final newResult = ScrapScanResult(
        id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        grade: grade,
        confidence: conf,
        weightKg: 2.0,
        pricePerKg: pricePerKg,
        timestamp: DateTime.now(),
        actionRecommendation: action,
        isSellNow: sellNow,
      );

      widget.appState.addScanResult(newResult);

      setState(() {
        _isScanning = false;
        _lastResult = newResult;
        _detectedLabel = "YOLO Detected: ${top.className} (${(conf * 100).toStringAsFixed(1)}%)";
      });
    } else {
      // If API server is unreachable or didn't find waste, notify user
      final errorMsg = response.errorMessage ?? 'No waste items detected in photo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.deepOrange,
        ),
      );

      setState(() {
        _isScanning = false;
      });
    }
  }

  void _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        await _processImageForYolo(bytes, photo.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    }
  }

  void _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImageForYolo(bytes, image.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e')),
        );
      }
    }
  }

  void _triggerSimulatedScan(MaterialCategory cat) {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final newResult = ScrapScanResult(
        id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        grade: QualityGrade.gradeA,
        confidence: 0.95,
        weightKg: 3.0,
        pricePerKg: 15.0,
        timestamp: DateTime.now(),
        actionRecommendation: 'SIMULATED DEMO',
        isSellNow: true,
      );
      widget.appState.addScanResult(newResult);
      setState(() {
        _isScanning = false;
        _lastResult = newResult;
        _detectedLabel = "Demo Material: ${cat.displayName}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      Text(
                        "Material Identifier",
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
              const SizedBox(height: 6),
              Text(
                "Detects Plastic, Paper, and Metal (cans & scrap metals). AI calculates purity grade and local junk shop valuation.",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 18),

              // Camera Viewfinder Box
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background: Show picked/captured image if available, else standard placeholder
                    if (_scannedImageBytes != null)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.memory(
                            _scannedImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isScanning
                                  ? Icons.sync_rounded
                                  : Icons.center_focus_strong_rounded,
                              size: 64,
                              color: _isScanning
                                  ? Colors.greenAccent
                                  : Colors.white.withAlpha(120),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isScanning
                                  ? "RUNNING YOLO INFERENCE..."
                                  : "Keep recyclables centered in frame",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: _isScanning
                                    ? Colors.greenAccent
                                    : Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Detected YOLO Label Overlay Banner
                    if (_detectedLabel != null)
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.greenAccent, width: 1.5),
                          ),
                          child: Text(
                            _detectedLabel!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Target Reticle Corners
                    Positioned(
                      left: 30,
                      top: 40,
                      child: _buildCorner(isTop: true, isLeft: true),
                    ),
                    Positioned(
                      right: 30,
                      top: 40,
                      child: _buildCorner(isTop: true, isLeft: false),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 40,
                      child: _buildCorner(isTop: false, isLeft: true),
                    ),
                    Positioned(
                      right: 30,
                      bottom: 40,
                      child: _buildCorner(isTop: false, isLeft: false),
                    ),

                    // Top Controls (Flash, Macro)
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "YOLO Waste Model",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() => _isFlashOn = !_isFlashOn);
                                },
                                icon: Icon(
                                  _isFlashOn
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  color: _isFlashOn ? Colors.amber : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() => _isMacroOn = !_isMacroOn);
                                },
                                icon: Icon(
                                  Icons.center_focus_weak_rounded,
                                  color: _isMacroOn ? Colors.greenAccent : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Active Scanning Bar Overlay
                    if (_isScanning)
                      const Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _captureFromCamera,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        _isScanning ? "INSPECTING..." : "TAKE PHOTO",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _isScanning ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text(
                        "GALLERY",
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fast Test Sample Selectors
              Text(
                "Or simulate material detection:",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MaterialCategory.values.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(cat.shortCode),
                        onPressed: _isScanning
                            ? null
                            : () => _triggerSimulatedScan(cat),
                        avatar: Icon(_getCategoryIcon(cat), size: 16),
                        backgroundColor: isDark
                            ? AppColors.surfaceContainerHighDark
                            : AppColors.surfaceContainerHighLight,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // AI Inspection Result Card
              if (_lastResult != null) _buildScanResultCard(context, _lastResult!, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildScanResultCard(
    BuildContext context,
    ScrapScanResult result,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "DETECTION SUCCESS",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              Text(
                "${(result.confidence * 100).toStringAsFixed(1)}% Match",
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          Text(
            result.category.displayName,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.grade.nameLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price & Weight Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ESTIMATED UNIT PRICE",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₱${result.pricePerKg.toStringAsFixed(2)} / kg",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "EST. BATCH VALUE (${result.weightKg} kg)",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₱${result.totalEstimatedValue.toStringAsFixed(2)}",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recommendation Chip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.isSellNow
                  ? AppColors.success.withAlpha(30)
                  : Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  result.isSellNow
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_rounded,
                  color: result.isSellNow ? AppColors.success : Colors.amber.shade900,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACTION RECOMMENDATION",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: result.isSellNow
                              ? AppColors.success
                              : Colors.amber.shade900,
                        ),
                      ),
                      Text(
                        result.actionRecommendation,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.plastic:
        return Icons.local_drink_outlined;
      case MaterialCategory.metal:
        return Icons.view_in_ar_outlined; // Cans and metal items
      case MaterialCategory.paper:
        return Icons.inventory_2_outlined; // Paper & cardboard
    }
  }
}
