# ADR-003 : Entraînement on-premise, inférence sur Azure

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Remplacé par ADR-017 |
| Exigences liées | F4, NF9 |

## Contexte

L'entraînement du modèle de prédiction consomme l'historique complet des
mesures, c'est-à-dire la donnée brute qui ne doit pas quitter le
on-premise (ADR-001). L'inférence, elle, est appelée par le dashboard : sa
charge est imprévisible et elle ne manipule que des artefacts non sensibles.

## Options étudiées

- **Option A — Tout on-premise (entraînement et inférence)**
  - avantages : aucune donnée ni artefact hors du périmètre.
  - inconvénients : pics d'inférence absorbés par le serveur de référence,
    aucune élasticité.
- **Option B — Tout sur Azure**
  - avantages : élasticité sur les deux charges, outillage ML managé.
  - inconvénients : impose de sortir l'historique brut, contradictoire avec
    l'ADR-001.
- **Option C — Entraînement on-premise, inférence sur Azure**
  - avantages : la donnée brute reste chez nous, l'inférence bénéficie de
    l'élasticité du cloud.
  - inconvénients : il faut transférer et versionner les artefacts de
    modèle entre les deux environnements.

## Décision

Entraînement on-premise sur l'historique brut, publication du modèle retenu
dans le registre MLflow (ADR-010), puis déploiement de l'artefact pour
l'inférence sur Azure.

## Conséquences

Un pipeline de promotion d'artefacts est nécessaire entre les deux
environnements et dépend du lien inter-environnements (ADR-015) ;
l'entraînement est limité aux ressources CPU du serveur on-premise ; les
versions de modèle en production sont tracées par MLflow.

À réexaminer si le temps d'entraînement devient bloquant (besoin de GPU
cloud) ou si l'inférence doit accéder à des données brutes.

## Amendements

02/09/2026 — décision d'architecture V2 — remplacé par [ADR-017](ADR-017-pivot-tout-on-premise.md) : l'inférence tourne on-premise aux côtés de l'entraînement ; la promotion des modèles passe par le registre MLflow sur la même VM, sans pipeline inter-environnements.
