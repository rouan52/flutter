<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $userId = $data['user_id'] ?? null;
    $sessionId = $data['session_id'] ?? null;
    $participate = $data['participate'] ?? null;
    $comment = $data['comment'] ?? null;

    if (!$userId || !$sessionId || $participate === null) {
        echo json_encode(['success' => false, 'message' => 'Paramètres manquants']);
        exit;
    }

    $pdo = connexionPDO();

    try {
        $checkSql = "SELECT COUNT(*) FROM seance_cavalier 
                     WHERE refidcava = :user_id AND refidseance = :session_id";
        $checkStmt = $pdo->prepare($checkSql);
        $checkStmt->execute([
            'user_id' => $userId,
            'session_id' => $sessionId
        ]);
        $exists = $checkStmt->fetchColumn() > 0;

        if ($exists) {
            $sql = "UPDATE seance_cavalier 
                    SET present = :participate, 
                        commentaire = :comment 
                    WHERE refidcava = :user_id 
                    AND refidseance = :session_id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                'participate' => $participate,
                'user_id' => $userId,
                'session_id' => $sessionId,
                'comment' => $comment
            ]);
        } else {
            $sql = "INSERT INTO seance_cavalier (refidcava, refidseance, present, commentaire) 
                    VALUES (:user_id, :session_id, :participate, :comment)";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                'user_id' => $userId,
                'session_id' => $sessionId,
                'participate' => $participate,
                'comment' => $comment
            ]);
        }

        echo json_encode([
            'success' => true,
            'message' => $participate ? 'Présence enregistrée' : 'Absence enregistrée'
        ]);
    } catch (PDOException $e) {
        echo json_encode([
            'success' => false,
            'error' => 'Erreur: ' . $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'error' => 'Méthode non autorisée'
    ]);
}
?>