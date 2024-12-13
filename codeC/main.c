#include <stdio.h>
#include <stdlib.h>
#include "struct.h"
#include "fonctions.h"

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

    parcoursInfixe(racine);

    libererArbreAVL(racine);

    return 0;
}
