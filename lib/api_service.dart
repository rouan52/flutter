import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://172.20.10.3/equihorizon/Exemple%20API';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Tentative de connexion avec email: $email');

      String body =
          'emailcava=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}';

      print('Corps de la requête: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Données décodées: $data');
        return data;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<dynamic>> fetchCourses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cours.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['courses'];
        }
        throw Exception(data['error']);
      }
      throw Exception('Échec du chargement des cours');
    } catch (e) {
      print('Erreur lors de la récupération des cours: $e');
      throw Exception('Erreur lors de la récupération des cours: $e');
    }
  }

  Future<Map<String, dynamic>> toggleEnrollment(
      String userId, String courseId, bool enroll) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/toggle_enrollment.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'course_id': courseId,
          'action': enroll ? 'enroll' : 'unenroll',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data;
        }
        throw Exception(data['error']);
      }
      throw Exception('Échec de l\'opération');
    } catch (e) {
      print('Erreur lors de l\'inscription/désinscription: $e');
      throw Exception('Erreur lors de l\'inscription/désinscription: $e');
    }
  }

// api_service.dart
  Future<void> toggleSessionParticipation(
    String userId,
    String courseId,
    String sessionId,
    bool participate, {
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/toggle_session.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'course_id': courseId,
          'session_id': sessionId,
          'participate': participate ? '1' : '0',
          if (comment != null) 'comment': comment,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (!data['success']) {
        throw Exception(data['error'] ?? 'Une erreur est survenue');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_profile.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['user'];
        }
        throw Exception(data['message']);
      }
      throw Exception('Échec du chargement du profil');
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<void> markAbsence(
      String userId, String sessionId, String reason) async {
    print(
        'Envoi des données - userId: $userId, sessionId: $sessionId, raison: $reason');

    final response = await http.post(
      Uri.parse('$baseUrl/mark_absence.php'),
      body: {
        'user_id': userId,
        'session_id': sessionId,
        'commentaire': reason,
      },
    );

    print('Réponse du serveur: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (!data['success']) {
      throw Exception(data['error'] ?? 'Une erreur est survenue');
    }

    // Afficher les données de debug si disponibles
    if (data['debug'] != null) {
      print('Debug serveur: ${data['debug']}');
    }
  }

  Future<List<dynamic>> fetchCourseSessions(
      String courseId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/get_course_sessions.php?course_id=$courseId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['sessions'];
        }
        throw Exception(data['message']);
      }
      throw Exception('Échec du chargement des séances');
    } catch (e) {
      print('Erreur lors de la récupération des séances: $e');
      throw Exception('Erreur lors de la récupération des séances: $e');
    }
  }

  Future<void> markAbsence(
      String userId, String sessionId, String commentaire) async {
    final response = await http.post(
      Uri.parse('http://your-api-url/mark_absence.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'user_id': userId,
        'session_id': sessionId,
        'commentaire': commentaire,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark absence: ${response.body}');
    }
  }
}
