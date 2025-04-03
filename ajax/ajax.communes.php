<?php
$keyword = $_POST['keyword'];
$type = $_POST['type'];

// Connexion à la base de données
$pdo = new PDO('mysql:host=localhost;dbname=commune', 'username', 'password');

// Requête pour récupérer les villes ou codes postaux
if ($type === 'ville') {
    $stmt = $pdo->prepare("SELECT ville_nom FROM villes_france_free WHERE ville_nom LIKE :keyword LIMIT 10");
} else {
    $stmt = $pdo->prepare("SELECT ville_code_postal FROM villes_france_free WHERE ville_code_postal LIKE :keyword LIMIT 10");
}

$stmt->execute(['keyword' => $keyword . '%']);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Renvoie les résultats au format JSON
echo json_encode($results);
?>