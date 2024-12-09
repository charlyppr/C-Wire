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

# Vérification de l'option d'aide (-h)
if [[ "$*" == *"-h"* ]]; then
    afficher_aide
    exit 0
fi

# Vérification du nombre d'arguments
if [ "$#" -lt 3 ]; then
    echo "Erreur : Nombre de paramètres insuffisant."
    afficher_aide
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
    exit 1
fi

# Vérification de la validité du type de station
if [[ "$type_station" != "hvb" && "$type_station" != "hva" && "$type_station" != "lv" ]]; then
    echo "Erreur : Type de station invalide. Valeurs possibles : hvb, hva, lv."
    afficher_aide
    exit 1
fi

# Vérification de la validité du type de consommateur
if [[ "$type_consommateur" != "comp" && "$type_consommateur" != "indiv" && "$type_consommateur" != "all" ]]; then
    echo "Erreur : Type de consommateur invalide. Valeurs possibles : comp, indiv, all."
    afficher_aide
    exit 1
fi

# Vérification des combinaisons interdites
if { [[ "$type_station" == "hvb" || "$type_station" == "hva" ]] && [[ "$type_consommateur" == "all" || "$type_consommateur" == "indiv" ]]; }; then
    echo "Erreur : Les combinaisons $type_station avec $type_consommateur sont interdites."
    afficher_aide
    exit 1
fi

# Si toutes les vérifications sont correctes, continuer avec le traitement
echo "Fichier CSV : $chemin_csv"
echo "Type de station : $type_station"
echo "Type de consommateur : $type_consommateur"
if [ -n "$identifiant_centrale" ]; then
    echo "Identifiant de centrale : $identifiant_centrale"
fi

# Vérifier la présence des dossiers tmp et graphs
tmp_dir="tmp"
graphs_dir="graphs"

# Vérifier et créer le dossier 'graphs' s'il n'existe pas
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

# Vérifier et créer le dossier 'tmp' s'il n'existe pas, sinon le vider
if [ ! -d "$tmp_dir" ]; then
    mkdir "$tmp_dir"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de créer le dossier '$tmp_dir'."
        exit 1
    fi
    echo "Dossier '$tmp_dir' créé."
else
    # Vider le dossier 'tmp'
    rm -rf "${tmp_dir:?}/"*
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de vider le dossier '$tmp_dir'."
        exit 1
    fi
    echo "Dossier '$tmp_dir' vidé."
fi

# Lancer le traitement (à compléter avec les autres tâches du script)
