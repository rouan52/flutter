<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? null;
    $courseId = $data['course_id'] ?? null;

    if (!$userId || !$courseId) {
        die(json_encode(['success' => false, 'message' => 'Missing user_id or course_id']));
    }

    $pdo = connexionPDO();
    if (!$pdo) {
        die(json_encode(['success' => false, 'message' => 'Database connection failed']));
    }

    try {
        $sql = "INSERT INTO inscrit (refidcours, refidcava, supprime) 
                VALUES (:course_id, :user_id, 0)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['course_id' => $courseId, 'user_id' => $userId]);
        echo json_encode(['success' => true, 'message' => 'Inscription réussie']);
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
    }
}
?>