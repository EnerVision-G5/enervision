# ADR-008 : React + Recharts (front et dataviz)

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F7 |

## Contexte

Le dashboard affiche des consommations par site, des prédictions et des
alertes, essentiellement sous forme de courbes temporelles rafraîchies
régulièrement. Il est livré en statique (ADR-004) et doit être produit dans
le temps du projet, avec les compétences présentes dans l'équipe.

## Options étudiées

- **Option A — React + Recharts**
  - avantages : compétences déjà présentes, composants de graphes
    déclaratifs couvrant courbes, aires et barres, intégration naturelle
    dans le rendu React.
  - inconvénients : personnalisation graphique limitée au-delà des
    graphiques standards.
- **Option B — React + D3 directement**
  - avantages : liberté totale sur la représentation.
  - inconvénients : deux modèles de rendu à concilier, coût de
    développement et de maintenance élevé pour des courbes classiques.
- **Option C — Vue + Chart.js**
  - avantages : prise en main rapide, rendu canvas performant.
  - inconvénients : écosystème que l'équipe maîtrise moins, aucun gain
    fonctionnel décisif.

## Décision

React pour le front et Recharts pour la dataviz : les visualisations
attendues sont des séries temporelles standards, que des composants
déclaratifs couvrent sans code de rendu spécifique.

## Conséquences

Le build produit des artefacts statiques compatibles avec ADR-004 ; les
graphiques restent dans le périmètre fonctionnel de Recharts, une
visualisation sur mesure imposerait une bibliothèque complémentaire ; le
volume de points affichés doit être borné côté API pour tenir le rendu.

À réexaminer si des visualisations avancées ou de très gros volumes de
points deviennent nécessaires.

## Amendements

—
