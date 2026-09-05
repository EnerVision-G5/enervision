# ADR-016 : Retrait de SonarQube de la chaîne qualité

| Champ | Valeur |
| --- | --- |
| Date | 06/09/2026 |
| Auteur | Équipe G5 |
| Statut | Accepté — amende ADR-012 |
| Exigences liées | NF1 |

## Contexte

ADR-012 retenait trois outils en intégration continue : Grype pour les
dépendances et les images, OWASP ZAP pour l'API en fonctionnement, SonarQube
pour l'analyse statique et la qualité du code. Les deux premiers tournent dans
les CI d'`api` et de `dashboard`. SonarQube n'a jamais été câblé : `predict`
portait un `sonar-project.properties` et publiait un rapport de couverture
« pour l'analyse » qu'aucun job ne consommait, et la checklist de Definition of
Done exigeait une porte qualité qui n'existait pas.

Deux obstacles concrets. SonarQube Cloud n'analyse les dépôts privés que sur
abonnement payant, et l'organisation est sur le plan GitHub gratuit. Un
SonarQube auto-hébergé demande un serveur, une base et un entretien que
l'équipe de quatre personnes ne peut pas porter sur la durée restante du
projet.

## Options étudiées

- **Option A — SonarQube Cloud, abonnement payant**
  - avantages : porte qualité intégrée aux pull requests, aucune machine à
    tenir.
  - inconvénients : coût récurrent pour un projet de deux semaines, mise en
    place et réglage des portes qualité sur trois dépôts.
- **Option B — SonarQube Community auto-hébergé sur la VM**
  - avantages : gratuit, analyse complète.
  - inconvénients : un service de plus sur la VM de production, base
    dédiée, exposition d'une interface d'administration, entretien ; hors de
    proportion avec le gain.
- **Option C — Retirer SonarQube, porter la qualité par les outils déjà en
  place**
  - avantages : rien à installer ni à payer, contrôles déjà bloquants dans
    chaque CI.
  - inconvénients : pas de mesure de dette technique ni de duplication ; la
    revue de code doit couvrir ce que l'outil aurait signalé.

## Décision

Option C. SonarQube est retiré de la chaîne. L'analyse statique et la qualité
sont portées par ce que chaque dépôt exécute déjà en CI et qui bloque la
fusion : `ruff` sur `api` et `predict`, ESLint et la vérification TypeScript
sur `dashboard`, `ansible-lint` sur `infra`, et la couverture `pytest`. Grype
et OWASP ZAP restent, bloquants, comme décidé par ADR-012.

## Conséquences

La checklist de Definition of Done ne peut plus exiger une « quality gate
SonarQube passée » : le critère devient « lint et couverture verts dans la CI
du dépôt ». `predict` retire `sonar-project.properties` et l'artefact de
couverture orphelin ; la couverture reste mesurée et son seuil devient une
condition de la suite de tests elle-même. Les mesures que SonarQube aurait
apportées seules, duplication et dette, relèvent de la relecture des pull
requests.

À réexaminer si le projet se poursuit au-delà de sa durée initiale, ou si un
plan GitHub payant rend SonarQube Cloud accessible sans coût supplémentaire.

## Amendements

—
