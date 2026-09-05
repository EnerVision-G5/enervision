# ADR-014 : Multi-repos + branches master → develop → feature, PR obligatoire

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté — amendé le 06/09/2026 (protection de branche) |
| Exigences liées | NF5 |

## Contexte

Le projet regroupe quatre composants au cycle de vie distinct — collecte et
API, dashboard, prédiction, infrastructure — développés en parallèle par
une équipe de cinq personnes. Il faut à la fois des livraisons
indépendantes par composant et un point d'entrée unique pour retrouver la
version cohérente de l'ensemble.

## Options étudiées

- **Option A — Monorepo**
  - avantages : une seule version pour tout, refactorisation transverse
    simple, une seule configuration de CI.
  - inconvénients : CI déclenchée pour tout le monde à chaque changement,
    droits et cycles de livraison indifférenciés.
- **Option B — Multi-repos indépendants**
  - avantages : cycles de vie et CI réellement séparés, périmètre de revue
    étroit.
  - inconvénients : aucune vue d'ensemble, difficile de désigner l'état
    cohérent du projet à un instant donné.
- **Option C — Multi-repos avec un repo racine en submodules**
  - avantages : indépendance des composants, plus un pointeur figé qui
    désigne la combinaison de versions qui fonctionne ensemble, et un lieu
    unique pour la documentation commune.
  - inconvénients : les pointeurs de submodules doivent être mis à jour
    explicitement, manipulation à expliquer à toute l'équipe.

## Décision

Quatre repos applicatifs (`api`, `dashboard`, `predict`, `infra`) et un
repo racine `enervision` qui les référence en submodules et porte la
documentation commune ; dans chaque repo, `master` reçoit ce qui est
livrable, `develop` intègre, et le travail se fait sur des branches de
fonctionnalité, avec pull request et revue obligatoires avant fusion.

## Conséquences

Aucun commit direct sur `master` ni sur `develop` : la protection de
branche doit être configurée sur chaque repo ; les contrôles de sécurité
(ADR-012) s'exécutent sur les pull requests ; une évolution transverse
touchant plusieurs composants demande plusieurs pull requests coordonnées
puis une mise à jour des pointeurs de submodules ; le contrat OpenAPI
(ADR-007) sert de point de synchronisation entre `api` et `dashboard`.

À réexaminer si le coût de coordination entre repos dépasse le bénéfice de
leur indépendance.

## Amendements

06/09/2026 — point D5 du cadrage tranché — la protection de branche prévue en
conséquence n'est **pas configurable** : les dépôts sont privés sur le plan
GitHub gratuit de l'organisation, qui n'offre ni protection de branche ni
rulesets (« Upgrade to GitHub Pro or make this repository public »). Les deux
issues, rendre les dépôts publics ou passer en plan Team, sont écartées pour la
durée du projet. La règle reste entière — aucun commit direct sur `master` ni
`develop`, pull request et revue avant fusion — mais elle est tenue par la
**discipline de l'équipe**, sans garde outillée : GitHub accepte techniquement
un push direct, et chacun s'engage à ne pas le faire. Deux compensations : la
CI de chaque dépôt se déclenche aussi sur `push` vers `develop` et `master`,
pour qu'un commit arrivé sans PR soit au moins testé ; et un push direct
constaté se corrige par une PR de suivi, jamais par une réécriture d'historique.
À rouvrir si l'organisation change de plan ou si les dépôts deviennent publics.
