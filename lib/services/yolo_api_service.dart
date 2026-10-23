import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class YoloDetection {
  final int classId;
  final String className;
  final double confidence;
  final List<double> box;

  YoloDetection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.box,
  });

  factory YoloDetection.fromJson(Map<String, dynamic> json) {
    return YoloDetection(
      classId: json['class_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? 'Waste',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      box: (json['box'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}

class YoloInferenceResponse {
  final bool success;
  final int totalDetected;
  final YoloDetection? topDetection;
  final List<YoloDetection> detections;
  final String? errorMessage;

  YoloInferenceResponse({
    required this.success,
    required this.totalDetected,
    this.topDetection,
    required this.detections,
    this.errorMessage,
  });

  factory YoloInferenceResponse.error(String message) {
    return YoloInferenceResponse(
      success: false,
      totalDetected: 0,
      detections: [],
      errorMessage: message,
    );
  }
}

class YoloApiService {
  // Use local PC IP 192.168.1.6 for physical phone over Wi-Fi, 127.0.0.1 for desktop/web
  static const String defaultApiUrl = 'http://192.168.1.6:8000/predict';
  static const String localhostApiUrl = 'http://127.0.0.1:8000/predict';

  static Future<YoloInferenceResponse> predictImageBytes(
    Uint8List bytes, {
    String filename = 'capture.jpg',
    String apiUrl = defaultApiUrl,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final list = (data['detections'] as List<dynamic>? ?? [])
            .map((item) => YoloDetection.fromJson(item as Map<String, dynamic>))
            .toList();

        YoloDetection? top;
        if (data['top_detection'] != null) {
          top = YoloDetection.fromJson(
            data['top_detection'] as Map<String, dynamic>,
          );
        } else if (list.isNotEmpty) {
          top = list.first;
        }

        return YoloInferenceResponse(
          success: true,
          totalDetected: data['total_detected'] as int? ?? list.length,
          topDetection: top,
          detections: list,
        );
      } else {
        return YoloInferenceResponse.error(
          'Inference server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return YoloInferenceResponse.error('API connection failed: $e');
    }
  }
}
