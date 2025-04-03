<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$pdo = connexionPDO();

try {
    $userId = $_POST['user_id'] ?? null;
    $courseId = $_POST['course_id'] ?? null;
    $sessionId = $_POST['session_id'] ?? null;
    $participate = $_POST['participate'] ?? '1';
    $comment = $_POST['comment'] ?? null;

    if (!$userId || !$courseId || !$sessionId) {
        throw new Exception('Paramètres manquants');
    }

    // Mettre à jour la participation
    $sql = "INSERT INTO participation (refidcava, refidcoursseance, participe, commentaire) 
            VALUES (:userId, :sessionId, :participate, :comment)
            ON DUPLICATE KEY UPDATE 
            participe = :participate,
            commentaire = :comment";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        'userId' => $userId,
        'sessionId' => $sessionId,
        'participate' => $participate,
        'comment' => $comment,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Participation mise à jour avec succès'
    ]);

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>