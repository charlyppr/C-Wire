# Configuration du terminal et de la sortie
set terminal pngcairo size 1200,800
set output 'graphs/lv_consommation.png'

# Arrière-plan thème sombre plus clair pour un meilleur contraste
set object 1 rectangle from screen 0,0 to screen 1,1 behind fc rgb "#353535" fillstyle solid 1.0

# Couleurs et style des éléments du graphique
set border lc rgb "#FFFFFF"
set grid ytics lc rgb "#888888" lt 2 dashtype 3
set key textcolor rgb "#FFFFFF"
set tics textcolor rgb "#FFFFFF"
set title textcolor rgb "#FFFFFF"
set xlabel textcolor rgb "#FFFFFF"
set ylabel textcolor rgb "#FFFFFF"

# Marges du graphique (à ajuster si besoin)
set lmargin at screen 0.15
set rmargin at screen 0.95
set bmargin at screen 0.15
set tmargin at screen 0.85

# Titres et labels avec polices plus grandes
set title "Consommation d'énergie par poste LV" font 'Helvetica Bold,24' offset 0, 1.5
set xlabel "Postes LV" font 'Helvetica,18' offset 0, -2
set ylabel "Consommation (kWh)" font 'Helvetica,18' offset -3, 0

# Personnalisation de la légende et des axes
set key top right font 'Helvetica,16'
set tics font 'Helvetica,16'
set xtics rotate by -45   # Incliner les étiquettes de l'axe X pour éviter le chevauchement

# Format des données
set datafile separator ":"

# Styles des barres
set style data histograms
set style histogram rowstacked
set style fill solid 1.0 noborder
set boxwidth 0.8 relative
set border 3

# Création du graphique
# $1 = Nom du poste LV
# $2 = Capacité (limite)
# $3 = Consommation
# Barre verte : min(consommation, capacité)
# Barre rouge : dépassement si consommation > capacité
plot 'lv_all_minmax.csv' using ($3>$2?$2:$3):xtic(1) title 'Consommation à la capacité' lc rgb "green", \
     '' using ($3>$2?$3-$2:0) title 'Consommation excédentaire' lc rgb "red"