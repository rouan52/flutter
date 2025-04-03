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
    $action = $data['action'] ?? null; // 'enroll' ou 'unenroll'

    if (!$userId || !$courseId || !$action) {
        echo json_encode([
            'success' => false,
            'error' => 'Paramètres manquants'
        ]);
        exit;
    }

    $pdo = connexionPDO();

    try {
        // Vérifier si l'inscription existe déjà
        $checkSql = "SELECT * FROM inscrit WHERE refidcours = :course_id AND refidcava = :user_id";
        $checkStmt = $pdo->prepare($checkSql);
        $checkStmt->execute(['course_id' => $courseId, 'user_id' => $userId]);
        $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

        if ($action === 'enroll') {
            if ($existing) {
                // Mettre à jour l'inscription existante
                $sql = "UPDATE inscrit SET supprime = 0 WHERE refidcours = :course_id AND refidcava = :user_id";
            } else {
                // Créer une nouvelle inscription
                $sql = "INSERT INTO inscrit (refidcours, refidcava, supprime) VALUES (:course_id, :user_id, 0)";
            }

            // Récupérer toutes les séances du cours
            $sessionsSql = "SELECT idcoursseance FROM calendrier WHERE idcoursbase = :course_id AND supprime = 0";
            $sessionsStmt = $pdo->prepare($sessionsSql);
            $sessionsStmt->execute(['course_id' => $courseId]);
            $sessions = $sessionsStmt->fetchAll(PDO::FETCH_ASSOC);

            // Créer les entrées dans la table participe pour chaque séance
            $participeSql = "INSERT INTO participe (refidcava, refidcoursbase, refidcoursseance, participe) 
                            VALUES (:user_id, :course_id, :session_id, 0)
                            ON DUPLICATE KEY UPDATE participe = 0";
            $participeStmt = $pdo->prepare($participeSql);

            foreach ($sessions as $session) {
                $participeStmt->execute([
                    'user_id' => $userId,
                    'course_id' => $courseId,
                    'session_id' => $session['idcoursseance']
                ]);
            }
        } else {
            // Désinscription (soft delete)
            $sql = "UPDATE inscrit SET supprime = 1 WHERE refidcours = :course_id AND refidcava = :user_id";
        }

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['course_id' => $courseId, 'user_id' => $userId]);

        echo json_encode([
            'success' => true,
            'message' => $action === 'enroll' ? 'Inscription réussie' : 'Désinscription réussie'
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