<?php
require_once 'connexionPDO.php';

// Activer l'affichage des erreurs pour le débogage
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Log pour voir si le script est appelé
error_log('Script login.php appelé');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Log des données reçues
    error_log('Données POST reçues : ' . print_r($_POST, true));
    error_log('Données RAW reçues : ' . file_get_contents('php://input'));
    
    $email = $_POST['emailcava'] ?? null;
    $password = $_POST['password'] ?? null;

    error_log('Email reçu : ' . ($email ?? 'null'));
    error_log('Password reçu : ' . ($password ? 'non-null' : 'null'));

    if (!$email || !$password) {
        error_log('Email ou mot de passe manquant');
        echo json_encode([
            'success' => false,
            'error' => 'Email ou mot de passe manquant'
        ]);
        exit;
    }

    try {
        $pdo = connexionPDO();
        
        // Récupérer l'utilisateur
        $sql = "SELECT idcava, password FROM cavaliers WHERE emailcava = :email AND supprime = 0";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        error_log('Requête SQL exécutée pour email: ' . $email);
        error_log('Utilisateur trouvé: ' . ($user ? 'oui' : 'non'));

        if ($user && password_verify($password, $user['password'])) {
            error_log('Connexion réussie pour: ' . $email);
            echo json_encode([
                'success' => true,
                'user_id' => $user['idcava'],
                'message' => 'Connexion réussie'
            ]);
        } else {
            error_log('Mot de passe incorrect pour: ' . $email);
            echo json_encode([
                'success' => false,
                'error' => 'Email ou mot de passe incorrect'
            ]);
        }
    } catch (PDOException $e) {
        error_log('Erreur PDO: ' . $e->getMessage());
        echo json_encode([
            'success' => false,
            'error' => 'Erreur de connexion à la base de données'
        ]);
    }
} else {
    error_log('Méthode non autorisée: ' . $_SERVER['REQUEST_METHOD']);
    echo json_encode([
        'success' => false,
        'error' => 'Méthode non autorisée'
    ]);
}
?>