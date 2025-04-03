<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Connexion à la base de données
$pdo = connexionPDO();
if (!$pdo) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

// Récupérer l'ID de l'utilisateur depuis les paramètres GET
$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    die(json_encode(['success' => false, 'message' => 'Missing user_id parameter']));
}

try {
    // Requête pour récupérer les cours inscrits de l'utilisateur
    $sql = "SELECT c.idcours, c.Libcours, c.jour, c.hdebut AS hdebut, c.hfin AS heurfin 
            FROM inscrit i 
            JOIN cours c ON i.refidcours = c.idcours 
            WHERE i.refidcava = :user_id AND i.supprime = 0";
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['user_id' => $userId]);
    $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($courses) {
        echo json_encode(['success' => true, 'courses' => $courses]);
    } else {
        echo json_encode(['success' => true, 'courses' => [], 'message' => 'No enrolled courses found']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>