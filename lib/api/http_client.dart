import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpClient {
  static const String baseUrl = 'http://54.253.211.96:8000/api';

  static Future<Map<String, dynamic>> patchUserUpdate({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('$baseUrl/users/update');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final resData = jsonDecode(response.body);
        return {'success': false, 'message': resData['detail'] ?? '오류 발생'};
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/users/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        return {'success': true, 'data': resData};
      } else {
        final resData = jsonDecode(response.body);
        return {
          'success': false,
          'message': resData['detail'] ?? '유저 정보 조회 실패',
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    File? imageFile, // nullable → 삭제 지원
  }) async {
    final uri = Uri.parse('$baseUrl/users/update');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('files', imageFile.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      return {
        'success': streamedResponse.statusCode == 200,
        'image_url': data['image_url'], 
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }
}
