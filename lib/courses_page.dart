import 'package:flutter/material.dart';
import 'api_service.dart';
import 'course_sessions_page.dart';

class CoursesPage extends StatefulWidget {
  final String userId;

  const CoursesPage({super.key, required this.userId});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final courses = await _apiService.fetchCourses(widget.userId);
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleEnrollment(
      Map<String, dynamic> course, bool enroll) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.toggleEnrollment(
        widget.userId,
        course['idcours'].toString(),
        enroll,
      );
      await _loadCourses(); // Recharger la liste des cours

      // Navigate to CourseSessionsPage after successful enrollment
      if (enroll) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseSessionsPage(
              userId: widget.userId,
              courseId: course['idcours'].toString(),
              courseName: course['nomcours'] ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours disponibles'),
        backgroundColor: Colors.brown,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.brown,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Equihorizon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menu de navigation',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon Profil'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: widget.userId,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCourses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    final isEnrolled = course['is_enrolled'] == 1;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête avec le statut d'inscription
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isEnrolled
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isEnrolled ? 'Inscrit' : 'Non inscrit',
                                style: TextStyle(
                                  color: isEnrolled
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Titre du cours
                            Text(
                              course['libcours'] ?? course['nomcours'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Horaire du cours
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.brown.shade300, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  course['jour'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time,
                                    color: Colors.brown.shade300, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${course['hdebut'] ?? ''} à ${course['hfin'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description du cours
                            if (course['description'] != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.brown.shade300, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        course['description'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Boutons d'action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (isEnrolled) ...[
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CourseSessionsPage(
                                              userId: widget.userId,
                                              courseId: course['idcours']
                                                      ?.toString() ??
                                                  '',
                                              courseName: course['nomcours'] ??
                                                  course['libcours'] ??
                                                  '',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                      label: const Text('Voir les séances'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.brown,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _toggleEnrollment(course, !isEnrolled),
                                    icon: Icon(isEnrolled
                                        ? Icons.person_remove
                                        : Icons.person_add),
                                    label: Text(
                                      isEnrolled
                                          ? 'Se désinscrire'
                                          : 'S\'inscrire',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEnrolled
                                          ? Colors.red
                                          : Colors.brown,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
