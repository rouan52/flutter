<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $userId = $_GET['user_id'] ?? null;

    if (!$userId) {
        echo json_encode([
            'success' => false,
            'message' => 'ID utilisateur manquant'
        ]);
        exit;
    }

    try {
        $pdo = connexionPDO();
        
        // Récupérer les informations du cavalier
        $sql = "SELECT 
                    c.nomcava,
                    c.prenomcava,
                    c.emailcava,
                    c.numlic,
                    c.telresp,
                    c.idgalop,
                    (SELECT COUNT(*) FROM inscrit WHERE refidcava = c.idcava AND supprime = 0) as total_courses
                FROM cavalier c
                WHERE c.idcava = :user_id";
                
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($userData) {
            echo json_encode([
                'success' => true,
                'user' => $userData
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Utilisateur non trouvé'
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Erreur: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Méthode non autorisée'
    ]);
}
?> 