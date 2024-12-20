#!/bin/bash

set -e

clear

# Fonction pour afficher l'aide
afficher_aide() {
    echo -e "Comment l'utiliser : ./c-wire.sh <chemin_csv> <type_station> <type_consommateur> [identifiant_centrale]\n"
    echo "Paramètres :"
    echo "  <chemin_csv>         : Chemin du fichier CSV des données"
    echo "  <type_station>       : Type de station (hvb | hva | lv)"
    echo "  <type_consommateur>  : Type de consommateur (comp | indiv | all)"
    echo "  [identifiant_centrale]: (Optionnel) Identifiant de la centrale"
    echo -e "\nExemple : ./c-wire.sh data.csv hva comp\n"
    echo -e "  [-h]                 : Affiche l'aide\n"
}

# Fonction pour afficher les combinaisons possibles
afficher_combinaisons() {
    echo -e "Combinaisons possibles :"
    echo -e "  \033[1mhvb comp\033[0m"
    echo -e "  \033[1mhva comp\033[0m"
    echo -e "  \033[1mlv comp\033[0m"
    echo -e "  \033[1mlv indiv\033[0m"
    echo -e "  \033[1mlv all\033[0m\n"
}

# Vérification de l'option d'aide (-h)
if [[ "$*" == *"-h"* ]]; then
    afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 0
fi

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo -e "\033[31mErreur : Nombre de paramètres insuffisant.\033[0m\n"
    afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
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
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 1
fi

# Vérification de la validité du type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo -e "\033[31mErreur : Type de station invalide. \n\033[1mValeurs possibles : hvb, hva, lv.\033[0m\n"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 1
fi

# Vérification de la validité du type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo -e "\033[31mErreur : Type de consommateur invalide. \n\033[1mValeurs possibles : comp, indiv, all.\033[0m\n"
    # afficher_aide
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 1
fi

# Vérification des combinaisons interdites
if { [[ "$type_station" == "hvb" || "$type_station" == "hva" ]] && [[ "$type_consommateur" == "all" || "$type_consommateur" == "indiv" ]]; }; then
    echo -e "\033[31mErreur : Les combinaisons \033[1m$type_station\033[0m\033[31m avec \033[1m$type_consommateur\033[0m\033[31m sont interdites.\033[0m\n"
    afficher_combinaisons
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 1
fi


tests_dir="tests"
tmp_dir="tmp"
graphs_dir="graphs"

# Vérification les dépendances
for cmd in awk gnuplot make gcc; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "\033[31mErreur : La commande '$cmd' n'est pas installée.\033[0m"
        exit 1
    fi
done

# Vérification de la présence des dossiers tmp et graphs
for dir in "$tests_dir" "$tmp_dir" "$graphs_dir"; do
    if [ ! -d "$dir" ]; then
        mkdir "$dir"
        echo -e "Dossier '\033[1m$dir\033[0m' a bien été créé."
    elif [ "$dir" == "$tmp_dir" ]; then
        rm -rf "${tmp_dir:?}/"*
        echo -e "Dossier '\033[1m$tmp_dir\033[0m' existe déjà et a bien été vidé."
    else
        echo -e "Dossier '\033[1m$dir\033[0m' existe déjà."
    fi
done

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

# Vérification de l'existence de l'identifiant_centrale
if [ -n "$identifiant_centrale" ]; then
    if ! grep -q "^$identifiant_centrale;" "$chemin_csv"; then
        echo -e "\033[31mErreur : l'identifiant de la centrale '$identifiant_centrale' n'existe pas dans le fichier CSV.\033[0m\n"
        echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
        exit 1
    fi
fi

# Construire les motifs de grep en fonction des paramètres
station_pattern=""
if [ -n "$identifiant_centrale" ]; then
    central_pattern="^$identifiant_centrale"
else
    central_pattern="^[0-9]+"
fi

case "$type_station" in
    "hvb") station_pattern="$central_pattern;[0-9]+;-;-;";;
    "hva") station_pattern="$central_pattern;[0-9-]+;[0-9]+;-;";;
    "lv") 
        case "$type_consommateur" in
            "comp") station_pattern="$central_pattern;-;[0-9-]+;[0-9]+;[0-9-]+;-;";;
            "indiv") station_pattern="$central_pattern;-;[0-9-]+;[0-9]+;-;[0-9-]+;";;
            "all") station_pattern="$central_pattern;-;[0-9-]+;[0-9]+;";;
        esac
esac

# Déterminer le numéro de la colonne de la ligne de la station
numero_ligne=""
case "$type_station" in
    "hvb") numero_ligne="2";;
    "hva") numero_ligne="3";;
    "lv") numero_ligne="4";;
esac

# Créer l'en-tête du fichier CSV
station_header=""
case "$type_station" in
    ("hvb") station_header="Station HVB";;
    ("hva") station_header="Station HVA";;
    ("lv") station_header="Station LV";;
esac

consumer_header=""
case "$type_consommateur" in
    ("comp") consumer_header="Consommation (entreprises)";;
    ("indiv") consumer_header="Consommation (particuliers)";;
    ("all") consumer_header="Consommation (tous)";;
esac

# Déterminer le nom du fichier de sortie
if [ -n "$identifiant_centrale" ]; then
    output_filename="${type_station}_${type_consommateur}_${identifiant_centrale}.csv"
else
    output_filename="${type_station}_${type_consommateur}.csv"
fi

header="${station_header}:Capacité en kWh:${consumer_header} en kWh"

# Écrire l'en-tête dans le fichier de sortie
echo "$header" > "$output_filename"

# Démarrer le chronomètre
debut=$(date +%s)

# Filtrage avec grep
grep -E "$station_pattern" "$chemin_csv" | cut -d ';' -f"$numero_ligne",7,8 | tr '-' '0' | ./codeC/programme | sort -t: -k2,2n >> $output_filename

# Vérifiez si le fichier filtre n'est pas vide
if [ ! -s "$output_filename" ]; then
    echo "\033[31mAucune donnée filtrée à traiter.\033[0m"
    echo -e "Durée de traitement : \033[1m0 seconde\033[0m\n"
    exit 0
fi

echo -e "Fichier '\033[1m$output_filename\033[0m' généré."

# Si on est dans le cas lv all et qu'il n'y a pas d'identifiant de centrale, on crée lv_all_minmax.csv
if [[ "$type_station" == "lv" && "$type_consommateur" == "all" && -z "$identifiant_centrale" ]]; then
    input_file="$output_filename"
    output_minmax="lv_all_minmax.csv"

    # Créer l'en-tête du fichier CSV
    echo "$header" > "$output_minmax"

    # Calculer les différences min et max
    awk -F: 'NR>1 { diff = $2 - $3; print $0 ":" diff }' "$input_file" | sort -t: -k4,4n | (head -n 10; tail -n 10) | cut -d: -f1-3 >> "$output_minmax"
    echo -e "Fichier '\033[1m$output_minmax\033[0m' généré."

    # Générer le graphique
    gnuplot input/graph.gp

    # Vérifier si le graphique a été créé
    if [ ! -f "$graphs_dir/lv_all_minmax.png" ]; then
        echo -e "\033[31mErreur : Le graphique 'lv_all_minmax.png' n'a pas été créé.\033[0m"
    fi

    echo -e "Graphique '\033[1mlv_all_minmax.png\033[0m' généré."
fi

echo -e "\n\033[1m\033[32mTraitement terminé avec succès.\033[0m"

# Arrêter le chronomètre
fin=$(date +%s)
duree=$(( $fin - $debut ))

# Afficher le temps de traitement
echo -e "\nDurée de traitement : \033[1m$duree secondes\033[0m\n"
