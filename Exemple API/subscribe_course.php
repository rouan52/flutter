<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$pdo = connexionPDO();
if (!$pdo) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

$cavalierId = $_POST['cavalier_id'] ?? null;
$coursId = $_POST['cours_id'] ?? null;

if (!$cavalierId || !$coursId) {
    die(json_encode(['success' => false, 'message' => 'Missing parameters']));
}

try {
    // Check if already enrolled
    $sql = "SELECT * FROM inscrit WHERE refidcours = :cours_id AND refidcava = :cavalier_id AND supprime = 0";
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['cours_id' => $coursId, 'cavalier_id' => $cavalierId]);
    if ($stmt->fetch()) {
        die(json_encode(['success' => false, 'message' => 'Already enrolled']));
    }

    // Enroll the user
    $sql = "INSERT INTO inscrit (refidcours, refidcava, supprime) VALUES (:cours_id, :cavalier_id, 0)";
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['cours_id' => $coursId, 'cavalier_id' => $cavalierId]);
    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>