import 'package:flutter/material.dart';

class InscritCoursPage extends StatelessWidget {
  final List<dynamic> cours;

  const InscritCoursPage({super.key, required this.cours});
  final String baseUql
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours Inscrits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vos cours inscrits :',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cours.length,
                itemBuilder: (context, index) {
                  final coursItem = cours[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(coursItem['Libcours']),
                      subtitle: Text(
                        '${coursItem['jour']} - ${coursItem['HD']} à ${coursItem['HF']}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
