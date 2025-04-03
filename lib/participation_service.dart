import 'dart:convert';
import 'package:http/http.dart' as http;

class ParticipationService {
  final String apiUrl = 'C:/xampp/htdocs/equihorizon'; // Remplacez par l'URL de votre API

  Future<bool> toggleParticipation(int userId, int courseId, int sessionId, bool isPresent) async {
    final action = isPresent ? 'enroll' : 'unenroll';
    final response = await http.post(
      Uri.parse('$apiUrl/toggle_session.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'course_id': courseId,
        'session_id': sessionId,
        'action': action,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['success'] ?? false;
    } else {
      // Gérer les erreurs ici
      print('Erreur lors de la requête: ${response.statusCode}');
      return false;
    }
  }
}
