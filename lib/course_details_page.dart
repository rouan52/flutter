import 'package:flutter/material.dart';
import 'api_service.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;
  final String userId;

  const CourseDetailsPage({
    super.key,
    required this.courseId,
    required this.userId,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  dynamic course;
  bool isLoading = true;
  bool isRegistered = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
    checkRegistrationStatus();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final data = await _apiService.fetchCourseDetails(widget.courseId);
      if (data['success']) {
        setState(() {
          course = data['course'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> checkRegistrationStatus() async {
    try {
      final courses = await _apiService.fetchEnrolledCourses(widget.userId);
      setState(() {
        isRegistered = courses.any(
          (c) => c['idCours'].toString() == widget.courseId,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> toggleRegistration() async {
    try {
      final response =
          isRegistered
              ? await _apiService.unsubscribeCourse(
                widget.userId,
                widget.courseId,
              )
              : await _apiService.subscribeCourse(
                widget.userId,
                widget.courseId,
              );
      if (response['success']) {
        setState(() => isRegistered = !isRegistered);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRegistered ? 'Inscrit!' : 'Désinscrit!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (course == null)
      return const Scaffold(body: Center(child: Text('Erreur de chargement')));

    return Scaffold(
      appBar: AppBar(title: Text(course['Libcours'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jour: ${course['jour']}'),
            Text('Horaire: ${course['HD']} - ${course['HF']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered ? Colors.red : Colors.green,
              ),
              child: Text(isRegistered ? 'Se désinscrire' : 'S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
