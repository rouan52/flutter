<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

$pdo = connexionPDO();

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $userId = $_POST['user_id'] ?? null;
        $courseId = $_POST['course_id'] ?? null;
        $enroll = $_POST['enroll'] ?? true;

        if ($enroll) {
            $pdo->beginTransaction();

            $stmt = $pdo->prepare("INSERT INTO inscrit (refidcava, refidcours) VALUES (:userId, :courseId)");
            $stmt->execute([
                'userId' => $userId,
                'courseId' => $courseId
            ]);

            $stmt = $pdo->prepare("SELECT idcoursseance FROM coursseance WHERE refidcours = :courseId");
            $stmt->execute(['courseId' => $courseId]);
            $sessions = $stmt->fetchAll();

            foreach ($sessions as $session) {
                $stmt = $pdo->prepare("INSERT INTO seance_cavalier (refidcava, refidseance, present) 
                                     VALUES (:userId, :sessionId, 1)");
                $stmt->execute([
                    'userId' => $userId,
                    'sessionId' => $session['idcoursseance']
                ]);
            }

            $pdo->commit();
        } else {
            $stmt = $pdo->prepare("UPDATE inscrit SET supprime = 1 WHERE refidcava = :userId AND refidcours = :courseId");
            $stmt->execute([
                'userId' => $userId,
                'courseId' => $courseId
            ]);
        }

        echo json_encode(['success' => true]);
        exit;
    }

    $userId = isset($_GET['user_id']) ? $_GET['user_id'] : null;
    
    $sql = "SELECT c.*, 
            CASE WHEN i.refidcava IS NOT NULL AND i.supprime = 0 THEN 1 ELSE 0 END as is_enrolled
            FROM cours c
            LEFT JOIN inscrit i ON c.idcours = i.refidcours AND i.refidcava = :user_id
            WHERE c.supprime = 0
            ORDER BY 
                CASE c.jour 
                    WHEN 'Lundi' THEN 1
                    WHEN 'Mardi' THEN 2
                    WHEN 'Mercredi' THEN 3
                    WHEN 'Jeudi' THEN 4
                    WHEN 'Vendredi' THEN 5
                    WHEN 'Samedi' THEN 6
                    ELSE 7
                END,
                c.hdebut";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['user_id' => $userId]);
    $cours = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'courses' => $cours
    ]);

} catch (PDOException $e) {
    if (isset($pdo)) {
        $pdo->rollBack();
    }
    echo json_encode([
        'success' => false,
        'error' => 'Erreur: ' . $e->getMessage()
    ]);
}
?>