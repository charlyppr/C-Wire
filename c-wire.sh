#!/bin/bash

clear

# Fonction pour afficher l'aide
afficher_aide() {
    echo -e "Comment l'utiliser : ./c-wire.sh <chemin_csv> <type_station> <type_consommateur>\n"
    echo "Paramètres :"
    echo "  <chemin_csv>         : Chemin vers le fichier CSV des données"
    echo "  <type_station>       : Type de station (hvb | hva | lv)"
    echo "  <type_consommateur>  : Type de consommateur (comp | indiv | all)"
    echo -e "\nExemple : ./c-wire.sh input/data.csv hva comp\n"
    echo -e "  [-h]                 : Affiche l'aide\n"
}

# Vérification de l'option d'aide (-h)
if [[ "$*" == *"-h"* ]]; then
    afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 0
fi

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo -e "\033[31mErreur : Nombre de paramètres insuffisant.\033[0m\n"
    afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 1
fi

# Assignation des arguments aux variables
chemin_csv="$1"
type_station="$2"
type_consommateur="$3"
identifiant_centrale="${4:-}"

# Vérification de la présence du fichier CSV
if [ ! -f "$chemin_csv" ]; then
    echo -e "\033[31mErreur : Le fichier CSV spécifié n'existe pas ou le chemin est incorrect.\033[0m"
    echo -e "Vérifier que le fichier est bien présent dans le dossier '\033[1minput\033[0m' et que son nom est correct.\n"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 1
fi

# Vérification de la validité du type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo -e "\033[31mErreur : Type de station invalide. \033[1mValeurs possibles : hvb, hva, lv.\033[0m"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 1
fi

# Vérification de la validité du type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo -e "\033[31mErreur : Type de consommateur invalide. \033[1mValeurs possibles : comp, indiv, all.\033[0m"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 1
fi

# Vérification des combinaisons interdites
if { [[ "$type_station" == "hvb" || "$type_station" == "hva" ]] && [[ "$type_consommateur" == "all" || "$type_consommateur" == "indiv" ]]; }; then
    echo -e "\033[31mErreur : Les combinaisons \033[1m$type_station\033[0m\033[31m avec \033[1m$type_consommateur\033[0m\033[31m sont interdites.\033[0m"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
    exit 1
fi


tests_dir="tests"
tmp_dir="tmp"
graphs_dir="graphs"

# Vérification de la présence des dossiers tmp et graphs
if [ ! -d "$graphs_dir" ]; then
    mkdir "$graphs_dir"
    if [ $? -ne 0 ]; then
        echo -e "\033[31mErreur : Impossible de créer le dossier '$graphs_dir'.\033[0m"
        exit 1
    fi
    echo -e "Dossier '\033[1m$graphs_dir\033[0m' a bien été créé."
else
    echo -e "Dossier '\033[1m$graphs_dir\033[0m' existe déjà."
fi

if [ ! -d "$tmp_dir" ]; then
    mkdir "$tmp_dir"
    if [ $? -ne 0 ]; then
        echo -e "\033[31mErreur : Impossible de créer le dossier '$tmp_dir'.\033[0m"
        exit 1
    fi
    echo -e "Dossier '\033[1m$tmp_dir\033[0m' a bien été créé."
else
    rm -rf "${tmp_dir:?}/"*
    if [ $? -ne 0 ]; then
        echo -e "\033[31mErreur : Impossible de vider le dossier '$tmp_dir'.\033[0m"
        exit 1
    fi
    echo -e "Dossier '\033[1m$tmp_dir\033[0m' existe déjà et a bien été vidé."
fi

# Vérifier et compiler le programme C
cd codeC
make clean
make
echo -e "\nCompilation du programme C..."
if [ $? -ne 0 ]; then
    echo -e "\033[31mErreur : La compilation du programme C a échoué.\033[0m\n"
    cd ..
    exit 1
fi
echo -e "\033[1m\033[32mCompilation réussie.\033[0m\n"
cd ..

# Démarrer le chronomètre
debut=$(date +%s)

# Filtrage des données
fichier_filtre="data_filtre.csv"

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
grep -E "$station_pattern" "$chemin_csv" | cut -d ';' -f"$numero_ligne",7,8 | tr '-' '0' > $tmp_dir/$fichier_filtre

echo -e "Fichier '\033[1m$fichier_filtre\033[0m' généré."

# Vérifiez si le fichier filtre n'est pas vide
if [ ! -s "$tmp_dir/$fichier_filtre" ]; then
    echo "\033[31mAucune donnée filtrée à traiter.\033[0m"
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m"
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
echo "$header" > "$tests_dir/$output_filename"

# Passer les données filtrées au programme C via un pipe et capturer la sortie
output=$(./codeC/programme < "$tmp_dir/$fichier_filtre")

# Vérifier si le programme C a retourné une sortie
if [ -z "$output" ]; then
    echo "\033[31mErreur : Le programme C n'a retourné aucune donnée.\033[0m"
    exit 1
fi

# Écrire les résultats dans le fichier de sortie
echo "$output" >> "$tests_dir/$output_filename"

echo -e "Fichier '\033[1m$output_filename\033[0m' généré."

# Si on est dans le cas lv all, on crée lv_all_minmax.csv
if [[ "$type_station" == "lv" && "$type_consommateur" == "all" ]]; then
    input_file="$tests_dir/$output_filename"
    output_minmax="lv_all_minmax.csv"

    # Calculer la différence entre la capacité et la consommation
    awk -F: 'NR>1 { diff = $2 - $3; print $0 ":" diff }' "$input_file" > $tmp_dir/lv_all_with_diff.csv

    # On trie les lignes par différence
    sort -t: -k4,4n $tmp_dir/lv_all_with_diff.csv > $tmp_dir/lv_all_sorted.csv

    # On prend les 10 premières lignes (les plus grandes différences)
    head -n 10 $tmp_dir/lv_all_sorted.csv | cut -d: -f1-3 > $tmp_dir/lv_all_top10_min.csv

    # On prend les 10 dernières lignes (les plus petites différences)
    tail -n 10 $tmp_dir/lv_all_sorted.csv | cut -d: -f1-3 > $tmp_dir/lv_all_top10_max.csv

    # Créer l'en-tête du fichier CSV
    echo "$header" > "$tests_dir/$output_minmax"

    # On combine les deux fichiers
    cat $tmp_dir/lv_all_top10_min.csv $tmp_dir/lv_all_top10_max.csv >> $tests_dir/"$output_minmax"
    # cat $tmp_dir/lv_all_top10_min.csv > "$output_minmax"

    gnuplot graph.gp

    echo -e "Fichier '\033[1m$output_minmax\033[0m' généré."
    echo -e "Graphique '\033[1mlv_all_minmax.png\033[0m' généré."
fi

# Arrêter le chronomètre
fin=$(date +%s)
duree=$(( $fin - $debut ))

# Afficher le temps de traitement
echo -e "\nDurée de traitement : \033[1m$duree secondes\033[0m"