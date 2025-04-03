<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$pdo = connexionPDO();

try {
    $userId = $_POST['user_id'] ?? null;
    $sessionId = $_POST['session_id'] ?? null;
    $commentaire = $_POST['commentaire'] ?? null;

    if (!$userId || !$sessionId || !$commentaire) {
        throw new Exception('Paramètres manquants');
    }

    // Check if the record exists
    $checkSql = "SELECT COUNT(*) FROM seance_cavalier 
                 WHERE refidcava = :userId AND refidseance = :sessionId";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([
        'userId' => $userId,
        'sessionId' => $sessionId
    ]);
    
    $exists = $checkStmt->fetchColumn() > 0;

    if ($exists) {
        // Update
        $sql = "UPDATE seance_cavalier 
                SET present = 1, 
                    commentaire = :commentaire 
                WHERE refidcava = :userId 
                AND refidseance = :sessionId";
    } else {
        // Insert
        $sql = "INSERT INTO seance_cavalier (refidcava, refidseance, present, commentaire) 
                VALUES (:userId, :sessionId, 0, :commentaire)";
    }

    $stmt = $pdo->prepare($sql);
    $success = $stmt->execute([
        'userId' => $userId,
        'sessionId' => $sessionId,
        'commentaire' => $commentaire
    ]);

    if (!$success) {
        throw new Exception('Erreur lors de l\'enregistrement de l\'absence');
    }

    echo json_encode([
        'success' => true,
        'message' => 'Absence enregistrée avec succès'
    ]);

    $stmt = $pdo->query("SELECT * FROM seance_cavalier LIMIT 1");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    //var_dump($result); // This will show the structure of the first row

    
    error_log(print_r($_POST, true)); // In mark_absence.php
    

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Erreur: ' . $e->getMessage()
    ]);
}
?> 