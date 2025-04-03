<?php
require_once 'connexionPDO.php';

$pdo = connexionPDO();

try {
    $userId = $_POST['user_id'] ?? null;
    $courseId = $_POST['course_id'] ?? null;

    if (!$userId || !$courseId) {
        throw new Exception('Paramètres manquants');
    }

    // Commencer une transaction
    $pdo->beginTransaction();

    // Inscrire au cours
    $stmt = $pdo->prepare("INSERT INTO inscrit (refidcava, refidcours) VALUES (:userId, :courseId)");
    $stmt->execute([
        'userId' => $userId,
        'courseId' => $courseId
    ]);

    // Récupérer toutes les séances du cours
    $stmt = $pdo->prepare("SELECT idcoursseance FROM coursseance WHERE refidcours = :courseId");
    $stmt->execute(['courseId' => $courseId]);
    $sessions = $stmt->fetchAll();

    // Inscrire automatiquement à toutes les séances
    foreach ($sessions as $session) {
        $stmt = $pdo->prepare("INSERT INTO participation (refidcava, refidcoursseance, participe) 
                              VALUES (:userId, :sessionId, 1)");
        $stmt->execute([
            'userId' => $userId,
            'sessionId' => $session['idcoursseance']
        ]);
    }

    // Valider la transaction
    $pdo->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Inscription réussie'
    ]);

} catch (Exception $e) {
    // Annuler la transaction en cas d'erreur
    $pdo->rollBack();
    echo json_encode([
        'success' => false,
        'error' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>