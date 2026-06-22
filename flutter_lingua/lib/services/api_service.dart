import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  late final Dio _dio;
  String _baseUrl;

  ApiService({required String baseUrl}) : _baseUrl = baseUrl {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  Future<String> transcribe(File audioFile, String language) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'language': language,
      });
      final response = await _dio.post('/transcribe', data: formData);
      return response.data['text'];
    } catch (e) {
      throw Exception('Failed to transcribe: $e');
    }
  }

  Future<Map<String, dynamic>> chat(
      String text, String language, List<Map<String, String>> history,
      {String userId = 'default'}) async {
    try {
      final response = await _dio.post('/chat', data: {
        'text': text,
        'language': language,
        'history': history,
        'user_id': userId,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to chat: $e');
    }
  }

  Future<File> speak(String text, String language) async {
    try {
      final response = await _dio.post('/speak', data: {
        'text': text,
        'language': language,
      }, options: Options(responseType: ResponseType.bytes));

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(response.data as List<int>);
      return file;
    } catch (e) {
      throw Exception('Failed to generate speech: $e');
    }
  }

  Future<Map<String, dynamic>> conversation(
      File audioFile, String language,
      {String userId = 'default', String? lessonId}) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'language': language,
        'user_id': userId,
      });
      if (lessonId != null) {
        formData.fields.add(MapEntry('lesson_id', lessonId));
      }
      final response = await _dio.post('/conversation', data: formData);
      return response.data;
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] ?? e.message : e.message;
      throw Exception('Conversation error (${e.response?.statusCode}): $detail');
    } catch (e) {
      throw Exception('Failed conversation: $e');
    }
  }

  Future<Map<String, dynamic>> translateAndSpeak({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'text': text,
        'target_language': targetLanguage,
      });
      final response = await _dio.post('/translate_and_speak', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to translate: $e');
    }
  }

  Future<Map<String, dynamic>> getStats(String userId) async {
    final response = await _dio.get('/stats/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> getVocabulary(String userId,
      {String? language}) async {
    final query = language != null ? '?language=$language' : '';
    final response = await _dio.get('/vocabulary/$userId$query');
    return response.data;
  }

  Future<List<dynamic>> getLessons({String? language}) async {
    final query = language != null ? '?language=$language' : '';
    final response = await _dio.get('/lessons$query');
    return response.data['lessons'] ?? [];
  }

  Future<Map<String, dynamic>> startLesson(
      String userId, String lessonId) async {
    final response = await _dio.post('/lessons/start', data: {
      'user_id': userId,
      'lesson_id': lessonId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getConversationHistory(String userId) async {
    final response = await _dio.get('/history/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> getProgress(String userId) async {
    final response = await _dio.get('/progress/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> pronounce(File audioFile, String referenceText, String language) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path),
        'reference_text': referenceText,
        'language': language,
      });
      final response = await _dio.post('/pronounce', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to score pronunciation: $e');
    }
  }
}
