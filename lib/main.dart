import 'package:flutter/material.dart';
import 'login_page.dart';
import 'courses_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Equihorizon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String?;
          if (userId == null) {
            return const LoginPage();
          }
          return CoursesPage(userId: userId);
        },
        '/profile': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String?;
          if (userId == null) {
            return const LoginPage();
          }
          return ProfilePage(userId: userId);
        },
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

final ApiService _apiService = ApiService();

Future<void> markSessionAbsence(String userId, String sessionId, String reason) async {
    try {
        final response = await http.post(
            Uri.parse('${ApiService.baseUrl}/mark_absence.php'),
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
            },
            body: jsonEncode({
                'user_id': userId,
                'session_id': sessionId,
                'commentaire': reason,
            }),
        );

        if (response.statusCode != 200) {
            throw Exception('Erreur serveur: ${response.statusCode}');
        }

        final data = json.decode(response.body);
        if (!data['success']) {
            throw Exception(data['error'] ?? 'Une erreur est survenue');
        }
    } catch (e) {
        throw Exception('Erreur de connexion: $e');
    }
}

class YourWidget extends StatefulWidget {
  final String userId;

  const YourWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  final ApiService _apiService = ApiService();

  Future<void> _markAbsence(Map<String, dynamic> session) async {
    final TextEditingController commentController = TextEditingController();
    
    final String? reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Raison de l\'absence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Veuillez indiquer la raison de votre absence pour cette séance'),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(hintText: 'Votre raison...'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.trim().isEmpty) {
                  // Afficher un message d'erreur
                  return;
                }
                Navigator.pop(context, commentController.text);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      try {
        await _apiService.markSessionAbsence(
          widget.userId,
          session['idcoursseance'].toString(),
          reason,
        );
        // Mettre à jour l'interface utilisateur pour refléter l'absence
      } catch (e) {
        // Gérer l'erreur
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue, utilisateur ${widget.userId}'),
      ),
      body: Center(
        child: Text('Contenu de votre widget'),
      ),
    );
  }
}
