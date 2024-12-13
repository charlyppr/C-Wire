# C-Wire

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
./c-wire.sh fichier_csv type_station type_consommateur
```

avec :

- **`fichier_csv`** : nom du fichier de données CSV

> [!IMPORTANT] 
> Pas besoin de mettre `input/data.csv` dans le terminal, `data.csv` est suffisant.

- **`type_station`** : Type de station électrique
    - hvb : Haute Tension B
    - hva : Haute Tension A
    - lv : Basse Tension

- **`type_consommateur`**  : Catégorie de consommateur
    - comp : Entreprises
    - indiv : Particuliers
    - all : Tous types

### Exemple d'utilisation
```bash
./c-wire.sh data.csv hvb comp
```

Ce qui précède exécute le programme en utilisant le fichier `data.csv`, en se concentrant sur les stations de type **HVB** et les consommateurs de type **entreprises**.

> [!WARNING] 
> Le fichier contenant les données doit se trouver dans le dossier `input`.  
