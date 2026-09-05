# Relevé de l'atelier de décision d'architecture — 31/08/2026

> Révisé par la [décision d'architecture V2 du 02/09/2026](2026-09-02-decision-architecture-v2-on-premise.md)
> et l'[ADR-017](../ADR/ADR-017-pivot-tout-on-premise.md) : l'architecture est
> intégralement on-premise. Le fil ci-dessous décrit l'état du 31/08 ; la
> colonne Statut du registre est tenue à jour.

| Champ | Valeur |
| --- | --- |
| Projet | EnerVision — Smart Energy Optimizer |
| Groupe | G5 |
| Date | 31/08/2026 |
| Objet | Converger les cinq dossiers EC01 vers une architecture unique |
| Livrables | 14 décisions actées (ADR-001 à ADR-014), 1 décision reportée (ADR-015) |

## Objectif de l'atelier

Chaque membre de l'équipe était arrivé avec sa propre proposition
d'architecture (dossiers EC01). L'atelier avait pour but de trancher, sur
chaque point structurant, une option unique partagée par l'équipe, et de
consigner pour chacune le contexte, les options écartées et les
conséquences — un ADR par décision, versionné avec le code.

## Fil de la décision

L'ordre des sujets a été imposé par leurs dépendances. Le choix
d'infrastructure a été traité en premier parce qu'il conditionnait tous les
autres : une fois la frontière de données posée (le brut et l'entraînement
restent on-premise, l'inférence et le dashboard vont sur Azure), le
placement du stockage, du ML et du dashboard découlait mécaniquement. Les
briques applicatives (ETL, back-end, front, ML) ont été décidées ensuite,
puis les décisions transverses (infrastructure as code, sécurité, secrets,
organisation Git).

Un seul sujet n'a pas pu être arbitré : le transport entre les deux
environnements, faute d'éléments suffisants sur le coût réel du VPN.

## Décisions actées

| N° | Titre | Statut | Exigences liées |
| --- | --- | --- | --- |
| [ADR-001](../ADR/ADR-001-infrastructure-hybride.md) | Infrastructure hybride à frontière de données | Remplacé par ADR-017 | NF7, NF8, NF9 |
| [ADR-002](../ADR/ADR-002-stockage-postgresql-timescaledb.md) | Stockage PostgreSQL + TimescaleDB | Accepté | F3 |
| [ADR-003](../ADR/ADR-003-entrainement-onprem-inference-azure.md) | Entraînement on-premise, inférence sur Azure | Remplacé par ADR-017 | F4, NF9 |
| [ADR-004](../ADR/ADR-004-dashboard-azure-static-web-apps.md) | Dashboard sur Azure Static Web Apps | Remplacé par ADR-017 | F7 |
| [ADR-005](../ADR/ADR-005-etl-python-cron-polling-1min.md) | ETL Python + cron, polling 1 minute | Accepté | F1, F2 |
| [ADR-006](../ADR/ADR-006-traitement-des-null.md) | Traitement des null : conservation brute + colonne imputée | Accepté | F3 |
| [ADR-007](../ADR/ADR-007-fastapi-backend.md) | FastAPI (back-end) | Accepté | F6 |
| [ADR-008](../ADR/ADR-008-react-recharts.md) | React + Recharts (front et dataviz) | Accepté | F7 |
| [ADR-009](../ADR/ADR-009-auth-jwt-oauth2.md) | Authentification JWT via OAuth2 | Accepté, amendé par ADR-017 | F6, NF1 |
| [ADR-010](../ADR/ADR-010-xgboost-mlflow.md) | XGBoost + MLflow | Accepté, amendé par ADR-017 | F4 |
| [ADR-011](../ADR/ADR-011-terraform-iac.md) | Terraform (IaC) | Remplacé par ADR-017 | NF6 |
| [ADR-012](../ADR/ADR-012-chaine-securite-grype-zap-sonarqube.md) | Chaîne sécurité Grype + OWASP ZAP + SonarQube | Amendé par ADR-016 | NF1 |
| [ADR-013](../ADR/ADR-013-secrets-key-vault.md) | Secrets : Azure Key Vault + fichiers env hors Git | Remplacé par ADR-017 | NF1 |
| [ADR-014](../ADR/ADR-014-multi-repos-branches-pr.md) | Multi-repos + branches master → develop → feature, PR obligatoire | Accepté | NF5 |
| [ADR-016](../ADR/ADR-016-retrait-sonarqube.md) | Retrait de SonarQube de la chaîne qualité (06/09/2026) | Accepté | NF1 |
| [ADR-017](../ADR/ADR-017-pivot-tout-on-premise.md) | Pivot tout on-premise (02/09/2026) | Accepté | NF1, NF6, NF7, NF8, NF9 |

L'ADR-001 a été adoptée par consensus ; les autres décisions en découlent ou
n'ont pas soulevé d'objection en séance.

## Point reporté

| N° | Titre | Statut | Échéance | Responsable |
| --- | --- | --- | --- | --- |
| [ADR-015](../ADR/ADR-015-lien-inter-environnements.md) | Lien inter-environnements (VPN / passerelle TLS) | Sans objet, remplacé par ADR-017 | — | — |

Deux options restaient en attente d'arbitrage : prototype de VPN site à
site, ou passerelle TLS applicative. Le point n'a jamais été tranché : la
décision V2 du 02/09/2026 supprime le second environnement, et avec lui le
lien à sécuriser.

## Suites à donner

- ~~Compléter l'ADR-015 après le prototype VPN~~ : sans objet depuis ADR-017.
- Ouvrir un ADR pour toute décision structurante ultérieure, et amender la
  fiche existante plutôt que d'en créer une nouvelle quand une décision
  n'est que révisée.
