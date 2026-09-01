# ADR-005 : ETL Python + cron, polling 1 minute

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F1, F2 |

## Contexte

Les mesures sont mises à disposition par une API Mock qu'il faut interroger
régulièrement, puis normaliser et charger en base (ADR-002). Le besoin
porte sur une seule source et une chaîne linéaire (extraction, nettoyage,
chargement), sans dépendances entre traitements.

## Options étudiées

- **Option A — Script Python déclenché par cron**
  - avantages : aucune brique supplémentaire, lisible, déployable sur le
    serveur on-premise en quelques lignes de configuration.
  - inconvénients : pas de reprise sur erreur ni de vue d'orchestration,
    supervision à construire à partir des logs.
- **Option B — Orchestrateur (Airflow)**
  - avantages : ordonnancement, retries, historique d'exécution, interface.
  - inconvénients : infrastructure et exploitation disproportionnées pour un
    unique flux.
- **Option C — Ingestion événementielle (broker de messages)**
  - avantages : temps réel, découplage producteur / consommateur.
  - inconvénients : la source est une API à interroger, pas un producteur
    d'événements ; complexité sans contrepartie.

## Décision

Script Python ordonnancé par cron, avec un polling d'une minute aligné sur
la fréquence de publication des mesures : la cadence la plus fine utile,
sans interroger la source pour rien.

## Conséquences

Le chargement doit être idempotent (contrainte d'unicité sur site plus
horodatage) pour absorber un rejeu ; l'absence de retry natif impose de
journaliser explicitement les échecs de collecte ; le traitement des
valeurs manquantes est défini par l'ADR-006.

À réexaminer si d'autres sources apparaissent, si des dépendances entre
traitements se créent, ou si la cadence d'une minute ne suffit plus.

## Amendements

—
