# ADR-011 : Terraform (IaC)

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Remplacé par ADR-017 |
| Exigences liées | NF6 |

## Contexte

L'architecture retenue comporte deux environnements (ADR-001) : des
ressources Azure pour l'inférence et le dashboard, et un serveur
on-premise. Le provisionnement doit être reproductible et revu comme du
code, sans clics manuels dont personne ne retrouve la trace.

## Options étudiées

- **Option A — Configuration manuelle via le portail Azure**
  - avantages : immédiat, aucune montée en compétence.
  - inconvénients : non reproductible, non revu, aucune trace des
    modifications ; incompatible avec NF6.
- **Option B — ARM / Bicep**
  - avantages : natif Azure, couverture immédiate des nouveautés du
    fournisseur.
  - inconvénients : limité à Azure, alors que le projet doit aussi décrire
    la cible on-premise.
- **Option C — Terraform**
  - avantages : un seul outil et un seul langage pour plusieurs cibles,
    plan d'exécution lisible en revue, état explicite des ressources.
  - inconvénients : état distant à héberger et à sécuriser, dérive possible
    si des modifications manuelles sont faites hors de l'outil.

## Décision

Terraform pour le provisionnement des ressources, complété par Ansible pour
la configuration du serveur on-premise : un même flux de revue couvre les
deux environnements.

## Conséquences

Le fichier d'état est stocké sur un backend distant et compte parmi les
éléments sensibles à protéger (ADR-013) ; toute modification passe par le
repo `infra` et sa revue (ADR-014) ; les changements manuels sur le portail
sont proscrits, sous peine de dérive entre l'état et le réel.

À réexaminer si le projet se limitait à une seule cible cloud, ou si
l'exploitation du fichier d'état devenait un point de friction.

## Amendements

02/09/2026 — décision d'architecture V2 — remplacé par [ADR-017](ADR-017-pivot-tout-on-premise.md) : Terraform est retiré du périmètre, il n'y a plus de cible cloud ; Ansible seul provisionne et configure la VM, le dépôt `infra` ne porte que lui.
