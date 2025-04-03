<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $courseId = $_GET['course_id'] ?? null;
    $userId = $_GET['user_id'] ?? null;

    if (!$courseId || !$userId) {
        echo json_encode(['success' => false, 'message' => 'Paramètres manquants']);
        exit;
    }

    $pdo = connexionPDO();
    if (!$pdo) {
        die(json_encode(['success' => false, 'message' => 'Database connection failed']));
    }

    try {
        // Requête pour récupérer les séances avec l'état de participation
        $sql = "SELECT 
                    cal.idcoursseance,
                    cal.datecours,
                    COALESCE(p.participe, 0) as participe
                FROM calendrier cal
                LEFT JOIN participe p ON cal.idcoursseance = p.refidcoursseance AND p.refidcava = :user_id
                WHERE cal.idcoursbase = :course_id AND cal.supprime = 0
                ORDER BY cal.datecours ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['course_id' => $courseId, 'user_id' => $userId]);
        $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'sessions' => $sessions]);
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
}
?> 