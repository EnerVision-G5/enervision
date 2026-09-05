# ADR-001 : Infrastructure hybride à frontière de données

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Remplacé par ADR-017 |
| Exigences liées | NF7, NF8, NF9 |

## Contexte

Converger les cinq dossiers EC01 vers une architecture unique ; données
industrielles sensibles (RGPD, Cloud Act), besoin d'élasticité pour
l'inférence et d'une exposition publique simple pour le dashboard.

## Options étudiées

- **Option A — Tout Azure**
  - avantages : élasticité, services managés, exposition publique triviale.
  - inconvénients : exposition Cloud Act de la donnée brute.
- **Option B — Tout on-premise**
  - avantages : souveraineté complète sur la donnée.
  - inconvénients : aucune élasticité, exposition publique portée par notre
    propre serveur.
- **Option C — Hybride à frontière de données**
  - avantages : le brut reste chez nous, le cloud sert l'élasticité et
    l'exposition publique.
  - inconvénients : deux environnements à outiller et à relier.

## Décision

Hybride : données brutes et entraînement on-premise (système de référence,
zéro exposition Cloud Act) ; inférence ML et dashboard sur Azure (artefacts
non sensibles, charge imprévisible, exposition publique séparée
physiquement de la donnée).

## Conséquences

Deux environnements à outiller (Terraform multi-cible, ADR-011) ; le lien
inter-environnements reste à trancher (ADR-015, échéance J4, resp. GL) ;
secrets partagés gérés via Key Vault (ADR-013).

À réexaminer si la classification des données change, ou si le coût et la
latence du lien inter-environnements deviennent bloquants.

## Amendements

02/09/2026 — décision d'architecture V2 — remplacé par [ADR-017](ADR-017-pivot-tout-on-premise.md) : l'architecture est intégralement on-premise sur la VM de l'école ; la frontière de résidence des données est portée à son maximum, plus rien ne sort du périmètre.
