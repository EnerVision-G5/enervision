# ADR-012 : Chaîne sécurité Grype + OWASP ZAP + SonarQube

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Amendé par ADR-016 (SonarQube retiré) |
| Exigences liées | NF1 |

## Contexte

L'exigence de sécurité couvre trois surfaces différentes : le code que nous
écrivons, les dépendances et images que nous embarquons, et l'API exposée
publiquement une fois déployée. Aucun outil ne couvre correctement les
trois, et les contrôles doivent être automatiques pour être réellement
appliqués.

## Options étudiées

- **Option A — Un seul outil généraliste**
  - avantages : une intégration, un rapport.
  - inconvénients : couverture partielle, angle mort sur au moins une des
    trois surfaces.
- **Option B — Revue manuelle avant livraison**
  - avantages : aucun outillage à mettre en place.
  - inconvénients : non reproductible, dépendant de la disponibilité de
    l'équipe, ne tient pas dans le rythme des livraisons.
- **Option C — Trois outils complémentaires en intégration continue**
  - avantages : chaque surface est couverte par l'outil adapté (SCA, DAST,
    SAST et qualité), rapports rejouables à chaque exécution.
  - inconvénients : trois intégrations à maintenir, durée de CI allongée,
    faux positifs à trier.

## Décision

Trois outils branchés dans la CI : Grype pour les vulnérabilités des
dépendances et des images, OWASP ZAP pour l'analyse dynamique de l'API
déployée, SonarQube pour l'analyse statique et la qualité du code.

## Conséquences

La CI est plus longue, ZAP nécessite un environnement déployé pour
s'exécuter ; des seuils de blocage doivent être définis explicitement, faute
de quoi les rapports seront ignorés ; les faux positifs doivent être tracés
plutôt que désactivés silencieusement ; les résultats sont attachés aux
pull requests (ADR-014).

À réexaminer si la durée de CI devient un frein, ou si un outil couvre à
lui seul plusieurs surfaces avec la même qualité.

## Amendements

06/09/2026 — retour de mise en place — SonarQube retiré de la chaîne, voir
[ADR-016](ADR-016-retrait-sonarqube.md) : jamais câblé, abonnement requis
pour des dépôts privés, auto-hébergement hors de proportion. Grype et OWASP
ZAP restent, bloquants.
