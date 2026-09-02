# ADR-006 : Traitement des null — conservation brute + colonne imputée

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F3 |

## Contexte

Le flux de mesures comporte des valeurs manquantes (capteur muet, réponse
partielle de la source). Ces trous gênent l'entraînement du modèle et
l'affichage des courbes, mais la base on-premise est le système de
référence (ADR-001) : ce qui y est écrit doit rester fidèle à ce que la
source a réellement publié.

## Options étudiées

- **Option A — Rejeter les lignes incomplètes**
  - avantages : base toujours propre, aucun traitement en aval.
  - inconvénients : perte d'information sur les périodes de panne, séries
    trouées de façon invisible.
- **Option B — Imputer directement à l'écriture**
  - avantages : une seule colonne à consommer, séries continues.
  - inconvénients : la valeur d'origine est perdue, l'imputation devient
    indiscernable d'une mesure réelle ; auditabilité nulle.
- **Option C — Conserver la valeur brute et ajouter une colonne imputée**
  - avantages : la donnée de référence reste intacte, chaque consommateur
    choisit sa colonne, l'imputation est traçable.
  - inconvénients : schéma plus large, méthode d'imputation à documenter et
    à maintenir.

## Décision

Conservation de la valeur brute telle que reçue (`null` compris) et ajout
d'une colonne imputée accompagnée d'un indicateur signalant les valeurs
reconstruites : la traçabilité prime sur la simplicité du schéma.

## Conséquences

Le schéma porte, pour chaque mesure, la valeur brute, la valeur imputée et
l'indicateur d'imputation ; la méthode d'imputation doit être documentée
avec le code de l'ETL (ADR-005) ; les requêtes du dashboard et les jeux
d'entraînement doivent expliciter la colonne qu'ils consomment ; le taux
d'imputation devient un indicateur de qualité à surveiller.

À réexaminer si le taux de valeurs manquantes devient élevé au point de
biaiser le modèle, ou si la source corrige ses trous a posteriori.

## Amendements

—
