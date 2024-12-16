# <img width="60" src="https://cdn-icons-png.flaticon.com/512/1534/1534189.png">&nbsp;&nbsp; C-Wire &nbsp;&nbsp; <img width="60" src="https://cdn-icons-png.flaticon.com/512/1534/1534189.png">&nbsp;&nbsp;

**MEF-2 • Trinome MEF-2_K**

## Table des Matières 
- [Introduction](#introduction)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Organisation des Fichiers](#organisation-des-fichiers)
- [Auteurs](#auteurs)

## Introduction

Le but de notre projet **C-Wire** vise à développer un programme permettant la synthèse de données d’un système de distribution d’électricité. Le programme analyse un vaste ensemble de données issues d’un fichier CSV détaillant la distribution d’électricité en France, depuis les centrales électriques jusqu’aux consommateurs finaux (entreprises et particuliers).

## Installation

### Prérequis

- **GnuPlot** : Pour la génération de graphiques  
  
Et c'est tout !

### L'installer

Pour installer ce projet, suivez les étapes ci-dessous :

1. **Cloner le dépôt GitHub**
```bash
git clone https://github.com/charlyppr/C-Wire
```

2. **Accédez au répertoire du projet** :
```bash
cd C-Wire
```

*Et voila ! 🎉*

## Utilisation

### Lancer le programme

Pour lancer le programme il suffit de tapper :

```bash
./c-wire.sh <chemin_csv> <type_station> <type_consommateur>
```

avec :

- **`chemin_csv`** : Chemin du fichier de données CSV

- **`type_station`** : Type de station électrique
    - **hvb** : Haute Tension B
    - **hva** : Haute Tension A
    - **lv** : Basse Tension

- **`type_consommateur`**  : Catégorie de consommateur
    - **comp** : Entreprises
    - **indiv** : Particuliers
    - **all** : Tous types

### Exemple d'utilisation
```bash
./c-wire.sh data.csv hvb comp
```

Ce qui précède exécute le programme en utilisant le fichier `data.csv`, en se concentrant sur les stations de type **HVB** et les consommateurs de type **entreprises**.

> [!WARNING] 
> Le fichier contenant les données `ficher_csv` doit se trouver dans le dossier `input`.  

## Organisation des fichiers

```yaml
C-Wire/
│ 
├── codeC/ 
│ ├── fonctions.h 
│ ├── main.c 
│ ├── makefile 
│ └── struct.h 
│ 
├── graphs/ 
│ 
├── input/ 
│ ├── fichier_csv.csv  // Fichier à ajouter
│ └── graph.gp 
│ 
├── tests/ 
│ 
├── tmp/ 
│ 
├── c-wire.sh 
│ 
└── README.md
```

## Auteurs

- **Charly Pupier** - [charly.pupier@etu.cyu.fr](mailto:charly.pupier@etu.cyu.fr)
- **Bouchra Zamoum** - [bouchra.zamoum@etu.cyu.fr](mailto:bouchra.zamoum@etu.cyu.fr)
- **Mathilde Nelva-Pasqual** - [mathilde.nelva-pasqual@etu.cyu.fr](mailto:mathilde.nelva-pasqual@etu.cyu.fr)