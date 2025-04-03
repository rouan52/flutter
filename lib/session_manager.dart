import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIdCava = 'idcava';
  static const String _keyNom = 'nomcava';
  static const String _keyPrenom = 'prenomcava';

  // Sauvegarder les données de session
  static Future<void> saveSession(int idcava, String nom, String prenom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyIdCava, idcava);
    await prefs.setString(_keyNom, nom);
    await prefs.setString(_keyPrenom, prenom);
  }

  // Récupérer l'ID de l'utilisateur
  static Future<int?> getIdCava() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyIdCava);
  }

  // Récupérer le nom
  static Future<String?> getNom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNom);
  }

  // Récupérer le prénom
  static Future<String?> getPrenom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrenom);
  }

  // Supprimer la session (déconnexion)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
