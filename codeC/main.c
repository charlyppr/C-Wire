#include <stdio.h>
#include <stdlib.h>

typedef struct NoeudAVL {
    int id_station;
    long consommation;
    long capacite;
    int hauteur;
    struct NoeudAVL* gauche;
    struct NoeudAVL* droite;
} NoeudAVL;

// Fonction pour créer un nouveau nœud AVL
NoeudAVL* creerNoeud(int id_station, long consommation, long capacite) {
    NoeudAVL* noeud = (NoeudAVL*)malloc(sizeof(NoeudAVL));
    if (!noeud) {
        fprintf(stderr, "Erreur d'allocation mémoire.\n");
        exit(EXIT_FAILURE);
    }
    noeud->id_station = id_station;
    noeud->consommation = consommation;
    noeud->capacite = capacite;
    noeud->hauteur = 1; // Nouveau nœud est initialement une feuille
    noeud->gauche = NULL;
    noeud->droite = NULL;
    return noeud;
}

// Fonction pour obtenir le maximum de deux entiers
int maximum(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour obtenir la hauteur d'un nœud
int hauteurNoeud(NoeudAVL* noeud) {
    if (noeud == NULL)
        return 0;
    return noeud->hauteur;
}

// Rotation droite
NoeudAVL* rotationDroite(NoeudAVL* y) {
    NoeudAVL* x = y->gauche;
    NoeudAVL* T2 = x->droite;

    // Effectuer la rotation
    x->droite = y;
    y->gauche = T2;

    // Mettre à jour les hauteurs
    y->hauteur = maximum(hauteurNoeud(y->gauche), hauteurNoeud(y->droite)) + 1;
    x->hauteur = maximum(hauteurNoeud(x->gauche), hauteurNoeud(x->droite)) + 1;

    // Retourner la nouvelle racine
    return x;
}

// Rotation gauche
NoeudAVL* rotationGauche(NoeudAVL* x) {
    NoeudAVL* y = x->droite;
    NoeudAVL* T2 = y->gauche;

    // Effectuer la rotation
    y->gauche = x;
    x->droite = T2;

    // Mettre à jour les hauteurs
    x->hauteur = maximum(hauteurNoeud(x->gauche), hauteurNoeud(x->droite)) + 1;
    y->hauteur = maximum(hauteurNoeud(y->gauche), hauteurNoeud(y->droite)) + 1;

    // Retourner la nouvelle racine
    return y;
}

// Fonction pour obtenir le facteur d'équilibre d'un nœud
int obtenirEquilibre(NoeudAVL* noeud) {
    if (noeud == NULL)
        return 0;
    return hauteurNoeud(noeud->gauche) - hauteurNoeud(noeud->droite);
}

// Fonction pour insérer un nœud dans l'arbre AVL
NoeudAVL* inserer(NoeudAVL* noeud, int id_station, long consommation, long capacite) {
    // 1. Effectuer l'insertion BST normale
    if (noeud == NULL)
        return creerNoeud(id_station, consommation, capacite);

    if (id_station < noeud->id_station)
        noeud->gauche = inserer(noeud->gauche, id_station, consommation, capacite);
    else if (id_station > noeud->id_station)
        noeud->droite = inserer(noeud->droite, id_station, consommation, capacite);
    else {
        // Si l'id_station existe déjà, ajouter la consommation et la capacité
        noeud->consommation += consommation;
        noeud->capacite += capacite;
        return noeud;
    }

    // 2. Mettre à jour la hauteur de l'ancêtre
    noeud->hauteur = 1 + maximum(hauteurNoeud(noeud->gauche), hauteurNoeud(noeud->droite));

    // 3. Obtenir le facteur d'équilibre pour vérifier si le nœud est déséquilibré
    int equilibre = obtenirEquilibre(noeud);

    // Cas de déséquilibre

    // Gauche Gauche
    if (equilibre > 1 && id_station < noeud->gauche->id_station)
        return rotationDroite(noeud);

    // Droite Droite
    if (equilibre < -1 && id_station > noeud->droite->id_station)
        return rotationGauche(noeud);

    // Gauche Droite
    if (equilibre > 1 && id_station > noeud->gauche->id_station) {
        noeud->gauche = rotationGauche(noeud->gauche);
        return rotationDroite(noeud);
    }

    // Droite Gauche
    if (equilibre < -1 && id_station < noeud->droite->id_station) {
        noeud->droite = rotationDroite(noeud->droite);
        return rotationGauche(noeud);
    }

    // Retourner le nœud inchangé
    return noeud;
}

// Fonction pour parcourir l'arbre en ordre et afficher les données
void parcoursInfixe(NoeudAVL* racine) {
    if (racine == NULL)
        return;
    parcoursInfixe(racine->gauche);
    printf("%d:%ld:%ld\n", racine->id_station, racine->capacite, racine->consommation);
    parcoursInfixe(racine->droite);
}

// Fonction pour libérer la mémoire de l'arbre AVL
void libererArbreAVL(NoeudAVL* racine) {
    if (racine == NULL)
        return;
    libererArbreAVL(racine->gauche);
    libererArbreAVL(racine->droite);
    free(racine);
}

int main() {
    NoeudAVL* racine = NULL;

    char ligne[256];
    while (fgets(ligne, sizeof(ligne), stdin)) {
        int id;
        long capacite = 0;
        long consommation = 0;
        if (sscanf(ligne, "%d;%ld;%ld", &id, &capacite, &consommation) != 3) {
            fprintf(stderr, "Format de ligne invalide: %s", ligne);
            continue;
        }
        racine = inserer(racine, id, consommation, capacite);
    }

    parcoursInfixe(racine);

    libererArbreAVL(racine);

    return 0;
}
