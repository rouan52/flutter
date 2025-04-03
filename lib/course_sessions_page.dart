import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';

class CourseSessionsPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;

  const CourseSessionsPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseSessionsPage> createState() => _CourseSessionsPageState();
}

class _CourseSessionsPageState extends State<CourseSessionsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final sessions = await _apiService.fetchCourseSessions(
        widget.courseId,
        widget.userId,
      );
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final List<String> months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Séances - ${widget.courseName}'),
        backgroundColor: Colors.brown,
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
                        onPressed: _loadSessions,
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
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final bool isAbsent = session['present'] == 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  color: Colors.brown.shade300,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatDate(session['datecours']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAbsent
                                        ? Colors.red.shade100
                                        : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isAbsent ? 'Absent' : 'Présent',
                                    style: TextStyle(
                                      color: isAbsent
                                          ? Colors.red.shade900
                                          : Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: isAbsent
                                      ? () async {
                                          await _apiService.toggleSessionParticipation(
                                            widget.userId,
                                            widget.courseId,
                                            session['idcoursseance'].toString(),
                                            true, // Marking as present
                                            comment: null, // No comment for presence
                                          );
                                          // Reload sessions to reflect the updated status
                                          await _loadSessions(); // Refresh the session data
                                        }
                                      : null,
                                  icon: const Icon(Icons.person),
                                  label: const Text('Marquer présent'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: !isAbsent
                                      ? () async {
                                          await _markAbsence(session);
                                        }
                                      : null,
                                  icon: const Icon(Icons.person_off),
                                  label: const Text('Marquer absent'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
        setState(() => _isLoading = true);
        await _apiService.toggleSessionParticipation(
          widget.userId,
          widget.courseId,
          session['idcoursseance'].toString(),
          false, // Marking as absent
          comment: reason, // Pass the reason for absence
        );
        setState(() {
          session['present'] = 0; // Update the session state
          session['commentaire'] = reason; // Store the reason in the session
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absence enregistrée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
