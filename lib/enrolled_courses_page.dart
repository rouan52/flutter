// enrolled_courses_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  List<dynamic> enrolledCourses = [];
  bool isLoading = true;
  late String userId;
  final ApiService _apiService = ApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    print('EnrolledCoursesPage userId: $userId'); // Log pour déboguer
    if (userId.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    fetchEnrolledCourses();
  }

  Future<void> fetchEnrolledCourses() async {
    try {
      final data = await _apiService.fetchEnrolledCourses(userId);
      setState(() {
        enrolledCourses = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> unsubscribe(String courseId) async {
    try {
      final response = await _apiService.unsubscribeCourse(userId, courseId);
      if (response['success']) {
        setState(() {
          enrolledCourses.removeWhere(
            (c) => c['idcours'].toString() == courseId,
          );
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Désinscrit avec succès')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours Inscrits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                ),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : enrolledCourses.isEmpty
              ? const Center(child: Text('Aucun cours inscrit'))
              : ListView.builder(
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = enrolledCourses[index];
                  return ListTile(
                    title: Text(course['Libcours']),
                    subtitle: Text(
                      '${course['jour']} ${course['hdebut']} - ${course['heurfin']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          () => unsubscribe(course['idcours'].toString()),
                    ),
                  );
                },
              ),
    );
  }
}
