# ADR-017 : Pivot tout on-premise

| Champ | Valeur |
| --- | --- |
| Date | 02/09/2026 (décision), 06/09/2026 (fiche) |
| Auteur | Équipe G5 au complet |
| Statut | Accepté — remplace ADR-001, ADR-003, ADR-004, ADR-011, ADR-013, ADR-015 ; amende ADR-009 et ADR-010 |
| Exigences liées | NF1, NF6, NF7, NF8, NF9 |

## Contexte

L'atelier du 31/08/2026 avait retenu une architecture hybride : données brutes
et entraînement on-premise, inférence et dashboard sur Azure, reliés par un
canal chiffré restant à trancher, avec Terraform pour la cible cloud et Azure
Key Vault pour les secrets. En cours de projet, deux faits ont pesé : l'accès
aux ressources Azure s'est révélé difficile, et l'équipe de quatre devait tenir
un planning J4-J7 avec deux environnements à outiller, sécuriser et monitorer.
Le détail de l'arbitrage est dans la
[décision V2 du 02/09/2026](../Decision/2026-09-02-decision-architecture-v2-on-premise.md).

## Options étudiées

- **Option A — Conserver l'hybride**
  - avantages : élasticité déléguée au cloud pour l'inférence et le front,
    décisions d'atelier inchangées.
  - inconvénients : deux environnements, un lien inter-environnements à
    sécuriser, deux outillages IaC, accès Azure incertain.
- **Option B — Tout Azure**
  - avantages : un seul environnement.
  - inconvénients : les données brutes quitteraient le périmètre souverain,
    contraire au principe directeur de l'atelier.
- **Option C — Tout on-premise sur la VM de l'école**
  - avantages : un seul environnement, aucune donnée ni artefact hors
    périmètre, coût marginal nul, un seul outil d'infrastructure.
  - inconvénients : plafond de capacité de la VM, élasticité assumée comme
    une limite.

## Décision

Option C. Toute la plateforme est déployée sur la VM on-premise en conteneurs
Docker Compose, provisionnée et configurée par Ansible seul, derrière Traefik
comme point d'entrée unique, avec Garage comme stockage objet compatible S3,
TimescaleDB, MLflow et la pile Prometheus, Grafana, Loki. Le service
d'inférence tourne sur la VM et n'est appelé que par l'API métier, jamais
exposé. Les secrets vivent dans un vault Ansible chiffré et des fichiers
d'environnement hors Git ; ceux de la CI dans GitHub Actions.

## Conséquences

- ADR-001 (hybride), ADR-003 (inférence Azure), ADR-004 (Static Web Apps),
  ADR-011 (Terraform), ADR-013 (Key Vault) sont remplacés ; ADR-015 (lien
  inter-environnements) devient sans objet avant d'avoir été tranché.
- ADR-009 reste valable, la clé de signature venant du vault Ansible et non
  de Key Vault ; ADR-010 reste valable, MLflow servant la promotion des
  modèles entre entraînement et inférence sur la même VM.
- Le dépôt `infra` ne porte plus qu'Ansible ; le dashboard ne parle qu'à l'API
  métier, qui interroge le service d'inférence et archive ses prédictions.
- La capacité est celle de la VM : la charge du pilote y tient largement, et
  la conteneurisation rend le déplacement d'un composant vers un cloud
  possible par changement de cible de déploiement.

À réexaminer si la charge dépasse la VM, si un client exige un hébergement
cloud, ou si l'accès à des ressources cloud redevient simple et gratuit.

## Amendements

—
