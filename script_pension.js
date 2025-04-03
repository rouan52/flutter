// Autocomplétion pour le champ "Nom Cavalier" dans le formulaire de modification
function autocompletCavaliermodif(id) {
    var keyword = $('#nomcava' + id).val();
    if (keyword.length == 0) {
        $('#nom_list_cavalier_id' + id).slideUp();
    } else {
        $.ajax({
            url: '../ajax/ajax.pension.idcavaajout.php',
            type: 'POST',
            data: {
                keyword: keyword,
                idpen: id
            },
            success: function(data) {
                $('#nom_list_cavalier_id' + id).html(data);
                $('#nom_list_cavalier_id' + id).slideDown();
            }
        });
    }

    var keywordT = $('#nomcavat' + id).val();
    if (keywordT.length == 0) {
        $('#nom_list_cavalier_idt' + id).slideUp();
    } else {
        $.ajax({
            url: '../ajax/ajax.pension.idcavaajout.php',
            type: 'POST',
            data: {
                keyword: keywordT,
                idpen: id
            },
            success: function(data) {
                $('#nom_list_cavalier_idt' + id).html(data);
                $('#nom_list_cavalier_idt' + id).slideDown();
            }
        });
    }
}

// Fonction pour sélectionner un cavalier dans la liste
function selectCavalier(idcava, nomcava, inputId) {
    $('#' + inputId).val(nomcava);
    $('#id' + inputId).val(idcava);
    $('#nom_list_cavalier_id' + inputId.replace('nomcava', '')).slideUp();
} 