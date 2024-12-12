#include <stdio.h>
#include <stdlib.h>

typedef struct NoeudAVL {
    int id_station;
    long consommation;
    long capacite;
    int equilibre;
    struct NoeudAVL* gauche;
    struct NoeudAVL* droite;
} NoeudAVL;

// Fonction pour créer un nouveau nœud AVL
NoeudAVL* creerNoeud(int id_station, long capacite, long consommation) {
    NoeudAVL* noeud = (NoeudAVL*)malloc(sizeof(NoeudAVL));
    if (!noeud) {
        fprintf(stderr, "Erreur d'allocation mémoire.\n");
        exit(EXIT_FAILURE);
    }
    noeud->id_station = id_station;
    noeud->capacite = capacite;
    noeud->consommation = consommation;
    noeud->equilibre = 0;
    noeud->gauche = NULL;
    noeud->droite = NULL;
    return noeud;
}

// Fonction pour obtenir les maximum et minimum
int maximum(int a, int b) {
    return (a > b) ? a : b;
}

int maximum3(int a, int b, int c) {
    return maximum(maximum(a, b), c);
}

int minimum(int a, int b) {
    return (a < b) ? a : b;
}

int minimum3(int a, int b, int c){
    return minimum(minimum(a, b), c);
}

// Rotation droite
NoeudAVL* rotationDroite(NoeudAVL* arbre) {
    NoeudAVL* pivot = arbre->gauche;
    int equilibre_a = arbre->equilibre;
    int equilibre_p = pivot->equilibre;

    arbre->gauche = pivot->droite;
    pivot->droite = arbre;

    arbre->equilibre = equilibre_a - minimum(equilibre_p, 0) + 1;
    pivot->equilibre = maximum3(equilibre_a + 2, equilibre_a + equilibre_p + 2, equilibre_p + 1);

    return pivot;
}

// Rotation gauche
NoeudAVL* rotationGauche(NoeudAVL* arbre) {
    NoeudAVL* pivot = arbre->droite;
    int equilibre_a = arbre->equilibre;
    int equilibre_p = pivot->equilibre;

    arbre->droite = pivot->gauche;
    pivot->gauche = arbre;

    arbre->equilibre = equilibre_a - maximum(equilibre_p, 0) - 1;
    pivot->equilibre = minimum3(equilibre_a - 2, equilibre_a + equilibre_p - 2, equilibre_p - 1);

    return pivot;
}

NoeudAVL* doubleRotationGauche(NoeudAVL* arbre) {
    arbre->droite = rotationDroite(arbre->droite);
    return rotationGauche(arbre);
}

NoeudAVL* doubleRotationDroite(NoeudAVL* arbre) {
    arbre->gauche = rotationGauche(arbre->gauche);
    return rotationDroite(arbre);
}

NoeudAVL* equilibrerAVL(NoeudAVL* a){
    if (a->equilibre >= 2) {
        if (a->droite->equilibre >= 0) {
            return rotationGauche(a);
        } else {
            return doubleRotationGauche(a);
        }
    }
    else if (a->equilibre <= -2) {
        if (a->gauche->equilibre <= 0) {
            return rotationDroite(a);
        } else {
            return doubleRotationDroite(a);
        }
    }
    return a; 
}


// Fonction pour insérer un nœud dans l'arbre AVL
NoeudAVL* inserer(NoeudAVL* noeud, int id_station, long capacite, long consommation, int* h) {
    if(noeud == NULL) {
        *h = 1;
        return creerNoeud(id_station, capacite, consommation);
    }

    if(id_station < noeud->id_station){
        noeud->gauche = inserer(noeud->gauche, id_station, capacite, consommation, h);
        *h = -*h;
    }
    else if(id_station > noeud->id_station){
        noeud->droite = inserer(noeud->droite, id_station, capacite, consommation, h);
    }
    else {
        // Station déjà existante, on ajoute capacité et consommation
        noeud->capacite += capacite;
        noeud->consommation += consommation;
        *h = 0;
        return noeud;
    }

    if (*h != 0) {
        noeud->equilibre += *h;
        noeud = equilibrerAVL(noeud);
        *h = (noeud->equilibre == 0) ? 0 : 1;
    }

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

    int h = 0;
    char ligne[256];
    while (fgets(ligne, sizeof(ligne), stdin)) {
        int id;
        long capacite = 0;
        long consommation = 0;
        if (sscanf(ligne, "%d;%ld;%ld", &id, &capacite, &consommation) != 3) {
            fprintf(stderr, "Format de ligne invalide: %s", ligne);
            continue;
        }
        racine = inserer(racine, id, capacite, consommation, &h);
    }

    // racine = inserer(racine, 1,241999040,0, &h);
    // racine = inserer(racine, 1,0,96811846, &h);
    // racine = inserer(racine, 1,0,28198359, &h);
    // racine = inserer(racine, 1,0,26074220, &h);
    // racine = inserer(racine, 1,0,20274618, &h);

    parcoursInfixe(racine);

    libererArbreAVL(racine);

    return 0;
}
