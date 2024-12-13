#ifndef STRUCT_H
#define STRUCT_H

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

#endif