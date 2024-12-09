#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    echo " "
    echo "Comment l'utiliser : c-wire.sh <chemin_csv> <type_station> <type_consommateur> [identifiant_centrale]"
    echo " "
    echo "Paramètres :"
    echo "  <chemin_csv>         : Chemin vers le fichier CSV des données (obligatoire)"
    echo "  <type_station>       : Type de station (hvb | hva | lv) (obligatoire)"
    echo "  <type_consommateur>  : Type de consommateur (comp | indiv | all) (obligatoire)"
    echo "  [identifiant_centrale]: Identifiant de centrale (optionnel)"
    echo " "
    echo "  [-h]                 : Affiche l'aide"
}

# Mesure du temps de début
start_time=$(date +%s)

# Vérification de l'option d'aide (-h)
if [[ "$*" == *"-h"* ]]; then
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 0
fi

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Erreur : Nombre de paramètres insuffisant."
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 1
fi

# Assignation des arguments aux variables
chemin_csv="$1"
type_station="$2"
type_consommateur="$3"
identifiant_centrale="${4:-}"

# Vérification de la présence du fichier CSV
if [ ! -f "$chemin_csv" ]; then
    echo "Erreur : Le fichier CSV spécifié n'existe pas ou le chemin est incorrect."
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 1
fi

# Vérification de la validité du type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Type de station invalide. Valeurs possibles : hvb, hva, lv."
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 1
fi

# Vérification de la validité du type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide. Valeurs possibles : comp, indiv, all."
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 1
fi

# Vérification des combinaisons interdites
if { [[ "$type_station" == "hvb" || "$type_station" == "hva" ]] && [[ "$type_consommateur" == "all" || "$type_consommateur" == "indiv" ]]; }; then
    echo "Erreur : Les combinaisons $type_station avec $type_consommateur sont interdites."
    afficher_aide
    echo "Durée de traitement : 0.0sec"
    exit 1
fi

# Vérification de la présence des dossiers tmp et graphs
tmp_dir="tmp"
graphs_dir="graphs"

if [ ! -d "$graphs_dir" ]; then
    mkdir "$graphs_dir"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de créer le dossier '$graphs_dir'."
        exit 1
    fi
    echo "Dossier '$graphs_dir' créé."
else
    echo "Dossier '$graphs_dir' existe déjà."
fi

if [ ! -d "$tmp_dir" ]; then
    mkdir "$tmp_dir"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de créer le dossier '$tmp_dir'."
        exit 1
    fi
    echo "Dossier '$tmp_dir' créé."
else
    rm -rf "${tmp_dir:?}/"*
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de vider le dossier '$tmp_dir'."
        exit 1
    fi
    echo "Dossier '$tmp_dir' vidé."
fi

# Vérifier la présence de l'exécutable C
if [ ! -f "./codeC/programme" ]; then
    echo "L'exécutable du programme C est introuvable. Lancement de la compilation..."
    make -C ./codeC
    if [ $? -ne 0 ]; then
        echo "Erreur : La compilation du programme C a échoué."
        echo "Durée de traitement : 0.0sec"
        exit 1
    fi
    echo "Compilation réussie."
fi

# Mesure du temps après préparation
process_start_time=$(date +%s)

# Filtrage des données
fichier_filtre="$tmp_dir/filtre.csv"
grep ";$type_station;" "$chemin_csv" | grep ";$type_consommateur;" > "$fichier_filtre"

# Lancer le programme C
./codeC/programme "$fichier_filtre" "$tmp_dir/resultats.csv"
if [ $? -ne 0 ]; then
    echo "Erreur lors de l'exécution du programme C."
    end_time=$(date +%s)
    process_duration=$(echo "$end_time - $process_start_time" | bc)
    echo "Durée de traitement : ${process_duration}.0sec"
    exit 1
fi

# Mesure du temps de fin
end_time=$(date +%s)

# Calcul de la durée de traitement
process_duration=$(echo "$end_time - $process_start_time" | bc)
echo "Durée de traitement : ${process_duration}.0sec"
echo "Traitement terminé avec succès. Les résultats sont dans $tmp_dir/resultats.csv."
