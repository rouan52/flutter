<?php
include '../include/bdd.inc.php';

if(isset($_POST['keyword'])) {
    $con = connexionPDO();
    $keyword = '%'.$_POST['keyword'].'%';

    $sql = "SELECT * FROM robe WHERE librobe LIKE (:var) ORDER BY idrobe ASC LIMIT 0, 100";
    $req = $con->prepare($sql);
    $req->bindParam(':var', $keyword, PDO::PARAM_STR);
    $req->execute();

    $list = $req->fetchAll();

    foreach ($list as $res) {
        $Listerobeajout = str_replace($_POST['keyword'], '<b>'.$_POST['keyword'].'</b>', $res['librobe']);
        // Utilise l'index `id` pour l'élément HTML, qui est passé depuis la fonction autocomplet() dans le JavaScript
        echo '<li onclick="set_item_robe_ajout(\''.str_replace("'", "\'", $res['librobe']).'\',  '.$res['idrobe'].')">'.$Listerobeajout.'</li>';
    }
}
?>