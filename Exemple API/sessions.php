<?php
require_once 'connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

$pdo = connexionPDO();
if (!$pdo) {
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

$courseId = $_GET['course_id'] ?? null;
$userId = $_GET['user_id'] ?? null;

if (!$courseId) {
    die(json_encode(['success' => false, 'message' => 'Missing course_id parameter']));
}

try {
    // Vérifier d'abord si l'utilisateur est inscrit au cours
    $checkEnrollmentSql = "SELECT * FROM inscrit 
                          WHERE refidcours = :course_id 
                          AND refidcava = :user_id 
                          AND supprime = 0";
    $checkStmt = $pdo->prepare($checkEnrollmentSql);
    $checkStmt->execute([
        'course_id' => $courseId,
        'user_id' => $userId
    ]);
    
    if (!$checkStmt->fetch()) {
        die(json_encode([
            'success' => false,
            'message' => 'Vous devez être inscrit au cours pour voir les séances'
        ]));
    }

    // Récupérer les séances
    $sql = "SELECT 
                MIN(cal.idcoursseance) as idcoursseance,
                cal.datecours,
                c.hdebut,
                c.hfin,
                COALESCE(p.participe, 0) as participe
            FROM calendrier cal
            JOIN cours c ON cal.idcoursbase = c.idcours
            LEFT JOIN (
                SELECT refidcoursseance, participe 
                FROM participe 
                WHERE refidcava = :user_id AND refidcoursbase = :course_id
            ) p ON cal.idcoursseance = p.refidcoursseance
            WHERE cal.idcoursbase = :course_id 
            AND cal.supprime = 0
            GROUP BY cal.datecours, c.hdebut, c.hfin
            ORDER BY cal.datecours ASC";
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        'course_id' => $courseId,
        'user_id' => $userId
    ]);
    $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Log pour le débogage
    error_log("Sessions trouvées: " . print_r($sessions, true));

    foreach ($sessions as &$session) {
        $date = new DateTime($session['datecours']);
        $session['datecours'] = $date->format('Y-m-d');
        
        if (isset($session['hdebut']) && isset($session['hfin'])) {
            $session['heures'] = $session['hdebut'] . ' à ' . $session['hfin'];
        }
    }

    echo json_encode([
        'success' => true, 
        'sessions' => $sessions
    ]);
} catch (PDOException $e) {
    error_log("Erreur SQL: " . $e->getMessage());
    echo json_encode([
        'success' => false, 
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>