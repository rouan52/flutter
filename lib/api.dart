import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://172.20.10.3/Equihorizon/Exemple%20API';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {'emailcava': email, 'password': password},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Échec de la connexion');
  }

  Future<List<dynamic>> fetchCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/cours.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) return data['courses'];
      throw Exception(data['message']);
    }
    throw Exception('Échec du chargement des cours');
  }

  Future<Map<String, dynamic>> fetchCourseDetails(String courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cours.php?id=$courseId'),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Échec du chargement des détails');
  }

  Future<List<dynamic>> fetchEnrolledCourses(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_enrolled_courses.php?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) return data['courses'];
      throw Exception(data['message']);
    }
    throw Exception('Échec du chargement des cours inscrits');
  }

  Future<Map<String, dynamic>> subscribeCourse(
    String userId,
    String courseId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscribe_course.php'),
      body: {'cavalier_id': userId, 'cours_id': courseId},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Échec de l\'inscription');
  }

  Future<Map<String, dynamic>> unsubscribeCourse(
    String userId,
    String courseId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/unsubscribe_course.php'),
      body: {'cavalier_id': userId, 'cours_id': courseId},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Échec de la désinscription');
  }
}
