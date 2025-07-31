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
    required File imageFile,
    required String imageUrl, 
  }) async {
    final uri = Uri.parse('$baseUrl/users/profile-image');
    final request =
        http.MultipartRequest('PATCH', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['image_url'] = imageUrl; 

    final exists = await imageFile.exists();
    final fileSize = await imageFile.length();

    if (!exists || fileSize == 0) {
      return {'success': false, 'message': '유효하지 않은 이미지 파일입니다.'};
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'image_url': data['image_url'],
          'message': data['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': '서버 오류 (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': '네트워크 오류: $e'};
    }
  }
}
