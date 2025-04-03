<?php
include '../include/bdd.inc.php';

if(isset($_POST['keyword'])) {
    $con = connexionPDO();
    $keyword = '%'.$_POST['keyword'].'%';

    $sql = "SELECT * FROM cavaliers WHERE nomcava LIKE (:var) ORDER BY idcava ASC LIMIT 0, 100";
    $req = $con->prepare($sql);
    $req->bindParam(':var', $keyword, PDO::PARAM_STR);
    $req->execute();

    $list = $req->fetchAll();

    // Ajout d'un style CSS pour rendre les éléments plus facilement cliquables
    echo '<style>
        .autocomplete-item {
            padding: 5px;
            cursor: pointer;
            background-color: white;
        }
        .autocomplete-item:hover {
            background-color: #f0f0f0;
        }
    </style>';

    foreach ($list as $res) {
        $Listecavaliersajout = str_replace($_POST['keyword'], '<b>'.$_POST['keyword'].'</b>', $res['nomcava']);
        if(isset($_POST['idpen'])) {
            // Pour le formulaire de modification
            echo '<div class="autocomplete-item" 
                      onclick="set_item_cava_modif(\''
                      .str_replace("'", "\'", $res['nomcava']).'\', '
                      .$res['idcava'].', '
                      .$_POST['idpen'].')">'
                      .$Listecavaliersajout.
                 '</div>';
        } else {
            // Pour le formulaire d'ajout
            echo '<div class="autocomplete-item" 
                      onclick="set_item_cava_ajout(\''
                      .str_replace("'", "\'", $res['nomcava']).'\', '
                      .$res['idcava'].')">'
                      .$Listecavaliersajout.
                 '</div>';
        }
    }
}
?>
