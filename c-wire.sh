#!/bin/bash

# Fonction pour afficher l'aide
afficher_aide() {
    echo " "
    echo "Comment l'utiliser : c-wire.sh <chemin_csv> <type_station> <type_consommateur>"
    echo " "
    echo "Paramètres :"
    echo "  <chemin_csv>         : Chemin vers le fichier CSV des données"
    echo "  <type_station>       : Type de station (hvb | hva | lv)"
    echo "  <type_consommateur>  : Type de consommateur (comp | indiv | all)"
    # echo "  [identifiant_centrale]: Identifiant de centrale"
    echo " "
    echo "  [-h]                 : Affiche l'aide"
}

# Vérification de l'option d'aide (-h)
if [[ "$*" == *"-h"* ]]; then
    afficher_aide
    echo "Durée de traitement : 0 sec"
    exit 0
fi

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Erreur : Nombre de paramètres insuffisant."
    afficher_aide
    echo "Durée de traitement : 0 sec"
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
    # afficher_aide
    echo "Durée de traitement : 0 sec"
    exit 1
fi

# Vérification de la validité du type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Type de station invalide. Valeurs possibles : hvb, hva, lv."
    # afficher_aide
    echo "Durée de traitement : 0 sec"
    exit 1
fi

# Vérification de la validité du type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide. Valeurs possibles : comp, indiv, all."
    # afficher_aide
    echo "Durée de traitement : 0 sec"
    exit 1
fi

# Vérification des combinaisons interdites
if { [[ "$type_station" == "hvb" || "$type_station" == "hva" ]] && [[ "$type_consommateur" == "all" || "$type_consommateur" == "indiv" ]]; }; then
    echo "Erreur : Les combinaisons $type_station avec $type_consommateur sont interdites."
    # afficher_aide
    echo "Durée de traitement : 0 sec"
    exit 1
fi


test_dir="tests"
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

# Vérifier et compiler le programme C
cd codeC
make clean
make
if [ $? -ne 0 ]; then
    echo "Erreur : La compilation du programme C a échoué."
    cd ..
    exit 1
fi
cd ..

# Démarrer le chronomètre
debut=$(date +%s)


# Filtrage des données
fichier_filtre="$tmp_dir/data_filtre.csv"

# Construire les motifs de grep en fonction des paramètres
station_pattern=""
case "$type_station" in
    "hvb") station_pattern="^[0-9]+;[0-9]+;-;-;";;
    "hva") station_pattern="^[0-9]+;[0-9-]+;[0-9]+;-;";;
    "lv") 
        case "$type_consommateur" in
            "comp") station_pattern="^[0-9]+;-;[0-9-]+;[0-9]+;[0-9-]+;-;";;
            "indiv") station_pattern="^[0-9]+;-;[0-9-]+;[0-9]+;-;[0-9-]+;";;
            "all") station_pattern="^[0-9]+;-;[0-9-]+;[0-9]+;";;
        esac
esac

# Déterminer le numéro de la colonne de la ligne de la station
numero_ligne=""
case "$type_station" in
    "hvb") numero_ligne="2";;
    "hva") numero_ligne="3";;
    "lv") numero_ligne="4";;
esac

# Filtrage avec grep
grep -E "$station_pattern" "$chemin_csv" | cut -d ';' -f"$numero_ligne",7,8 | tr '-' '0' > $fichier_filtre

# Vérifiez si le fichier filtre n'est pas vide
if [ ! -s "$fichier_filtre" ]; then
    echo "Aucune donnée filtrée à traiter."
    echo "Durée de traitement : 0 sec"
    exit 0
fi

# Déterminer le nom du fichier de sortie
output_filename="${type_station}_${type_consommateur}.csv"

# Créer l'en-tête du fichier CSV
station_header=""
case "$type_station" in
    "hvb") station_header="Station HVB";;
    "hva") station_header="Station HVA";;
    "lv") station_header="Station LV";;
esac

consumer_header=""
case "$type_consommateur" in
    "comp") consumer_header="Consommation (entreprises)";;
    "indiv") consumer_header="Consommation (particuliers)";;
    "all") consumer_header="Consommation (tous)";;
esac

header="${station_header}:Capacité en kWh:${consumer_header} en kWh"

# Écrire l'en-tête dans le fichier de sortie
echo "$header" > "$output_filename"

# Passer les données filtrées au programme C via un pipe et capturer la sortie
output=$(./codeC/programme < "$fichier_filtre")

# Vérifier si le programme C a retourné une sortie
if [ -z "$output" ]; then
    echo "Erreur : Le programme C n'a retourné aucune donnée."
    exit 1
fi

# Écrire les résultats dans le fichier de sortie
echo "$output" >> "$output_filename"

# Si on est dans le cas lv all, on crée lv_all_minmax.csv
if [[ "$type_station" == "lv" && "$type_consommateur" == "all" ]]; then
    input_file="$output_filename"
    output_minmax="lv_all_minmax.csv"

    # Calculer la différence entre la capacité et la consommation
    awk -F: 'NR>1 { diff = $2 - $3; print $0 ":" diff }' "$input_file" > $tmp_dir/lv_all_with_diff.csv

    # On trie les lignes par différence
    sort -t: -k4,4n $tmp_dir/lv_all_with_diff.csv > $tmp_dir/lv_all_sorted.csv

    # On prend les 10 premières lignes (les plus grandes différences)
    head -n 10 $tmp_dir/lv_all_sorted.csv | cut -d: -f1-3 > $tmp_dir/lv_all_top10_min.csv

    # On prend les 10 dernières lignes (les plus petites différences)
    tail -n 10 $tmp_dir/lv_all_sorted.csv | cut -d: -f1-3 > $tmp_dir/lv_all_top10_max.csv

    # On combine les deux fichiers
    cat $tmp_dir/lv_all_top10_min.csv $tmp_dir/lv_all_top10_max.csv > $test_dir/"$output_minmax"
    # cat $tmp_dir/lv_all_top10_min.csv > "$output_minmax"

    gnuplot graph.gp

    echo "Fichier $output_minmax généré."
fi

# Arrêter le chronomètre
fin=$(date +%s)
duree=$(( $fin - $debut ))

# Afficher le temps de traitement
echo "Durée de traitement : $duree secondes"