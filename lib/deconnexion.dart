import 'package:flutter/material.dart';

class MonProfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logique de déconnexion ici
              _deconnexion(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Détails du profil ici'),
      ),
    );
  }

  void _deconnexion(BuildContext context) {
    // Logique de déconnexion, par exemple, supprimer le token d'authentification
    // Puis rediriger vers la page de connexion
    Navigator.pushReplacementNamed(context, '/login');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MonProfil(),
      routes: {
        '/login': (context) => LoginPage(), // Remplacez par votre page de connexion
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Center(
        child: Text('Page de connexion ici'),
      ),
    );
  }
}
