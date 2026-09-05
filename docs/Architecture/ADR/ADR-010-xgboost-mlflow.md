# ADR-010 : XGBoost + MLflow

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté — amendé par ADR-017 |
| Exigences liées | F4 |

## Contexte

La prédiction de consommation s'appuie sur des séries temporelles tabulaires
enrichies de variables de calendrier (heure, jour, saisonnalité). Les
entraînements ont lieu on-premise sur CPU (ADR-003) et le modèle promu doit
être identifiable et reproductible une fois déployé sur Azure.

## Options étudiées

- **Option A — Modèle de référence simple (baseline naïve, régression
  linéaire)**
  - avantages : immédiat, interprétable, indispensable comme point de
    comparaison.
  - inconvénients : ne capte ni les effets non linéaires ni les
    interactions entre variables de calendrier.
- **Option B — XGBoost**
  - avantages : très bon sur données tabulaires, entraînement CPU rapide,
    importance des variables exploitable, peu de données nécessaires pour
    des résultats exploitables.
  - inconvénients : ingénierie de variables temporelles à la charge de
    l'équipe.
- **Option C — Réseau de neurones séquentiel (LSTM)**
  - avantages : modélise directement la dépendance temporelle.
  - inconvénients : volume de données et puissance de calcul supérieurs,
    coût d'entraînement incompatible avec le serveur on-premise.

## Décision

XGBoost pour le modèle, comparé systématiquement à une baseline naïve, et
MLflow pour le suivi des expérimentations et le registre des modèles :
c'est MLflow qui matérialise le passage on-premise vers Azure décidé en
ADR-003.

## Conséquences

Un serveur MLflow doit être hébergé et sauvegardé on-premise ; chaque
entraînement journalise ses paramètres, ses métriques et son artefact ; la
baseline est un livrable permanent, pas une étape jetable ; les variables
temporelles doivent être calculées de façon identique à l'entraînement et à
l'inférence.

À réexaminer si la qualité de prédiction plafonne malgré l'ingénierie de
variables, ou si des historiques bien plus longs deviennent disponibles.

## Amendements

02/09/2026 — décision d'architecture V2 ([ADR-017](ADR-017-pivot-tout-on-premise.md)) — la décision est inchangée ; MLflow matérialise la promotion des modèles entre entraînement et inférence sur la même VM, il n'y a plus de passage vers Azure. Le serveur MLflow et ses artefacts (Garage) sont on-premise.
