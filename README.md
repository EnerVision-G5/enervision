# enervision

[![ci](https://github.com/EnerVision-G5/enervision/actions/workflows/ci.yml/badge.svg)](https://github.com/EnerVision-G5/enervision/actions/workflows/ci.yml)

Repo chapeau du projet Smart Energy Optimizer (EnerVision). Il agrège les
services en submodules Git et porte les contrats d'interface qui font foi entre
les équipes.

## Submodules

| Submodule | Rôle |
| --- | --- |
| `api` | API métier FastAPI on-premise : sites, mesures, alertes, sous JWT |
| `predict` | Service d'inférence FastAPI sur Azure : prédictions XGBoost |
| `dashboard` | Front React + TypeScript (Vite) |
| `infra` | Infrastructure et déploiement |

Les quatre submodules suivent `develop`, la branche d'intégration de chaque
service (`branch = develop` dans `.gitmodules`). Le pointeur commité dans ce
dépôt est un instantané cohérent des quatre services, pas une version
déployée : ce qui tourne en production est décrit par `infra`.

Cloner avec les submodules :

```bash
git clone --recurse-submodules https://github.com/EnerVision-G5/enervision.git
```

Sur un clone déjà présent :

```bash
git submodule update --init --recursive
```

### Mise à jour des pointeurs

Les pointeurs avancent **une fois par jour**, par une PR ouverte
automatiquement chaque matin par le workflow `submodules-sync`, et à la
demande avant une démo ou une livraison (*Actions → submodules-sync → Run
workflow*). Pas à chaque merge dans un service : les quatre dépôts fusionnent
plusieurs fois par jour, et une PR par merge noierait la relecture pour des
pointeurs que seuls les humains consomment. Le coût est d'une minute
d'Actions par jour, contre plusieurs centaines par mois au rythme des merges.
Un jour sans merge n'ouvre rien : le workflow s'arrête quand les pointeurs
sont déjà à jour.

Le workflow pose chaque pointeur sur la tête de la branche suivie, vérifie que
les quatre se clonent, puis pousse la branche `submodules-sync` et ouvre ou
met à jour la PR correspondante. Relire, fusionner : `develop` du dépôt chapeau
rattrape les services.

Même geste à la main, depuis un clone à jour :

```bash
git submodule update --remote --recursive
git add api dashboard predict infra
git commit -m "Avancer les pointeurs de submodules sur les branches suivies"
```

## Contrats d'interface

`docs/contracts/` contient les spécifications OpenAPI gelées des deux
back-ends. Ce sont elles, et rien d'autre, qui font foi entre `api`,
`dashboard` et `predict`.

- `docs/contracts/openapi-api.json` : contrat de l'API métier.
- `docs/contracts/openapi-predict.json` : contrat du service d'inférence.
- `docs/contracts/README.md` : règle de gouvernance et procédure de
  modification.

Les fichiers ne sont jamais écrits à la main. Ils sont générés depuis les DTO
Pydantic des services, et le dashboard en dérive ses types TypeScript. Une
garde CI `contract-drift` fait échouer le build de `api` et de `predict` dès
que le code s'écarte du contrat gelé.

## Intégration continue

Deux workflows.

`.github/workflows/ci.yml` s'exécute sur chaque pull request, et sur `develop`
et `master` après fusion. Un seul job, qui vérifie deux choses :

- **les submodules sont récupérables** : `git submodule update --init
  --recursive` doit réussir sur les quatre pointeurs. Un pointeur vers un
  commit qui n'existe plus sur le dépôt de service (branche supprimée,
  historique réécrit) fait échouer la CI ;
- **la documentation Markdown du repo parent est conforme**
  (`markdownlint-cli2`, règles dans `.markdownlint.json`).

Chaque submodule porte en plus son propre pipeline lint / tests / build, avec
un badge de statut dans son README.

`.github/workflows/submodules-sync.yml` avance les pointeurs de submodules et
ouvre la PR de mise à jour (voir [Mise à jour des
pointeurs](#mise-à-jour-des-pointeurs)). Il tourne chaque jour à 06:00 UTC et
à la demande. Deux conditions côté GitHub :

- *Settings → Actions → General → Workflow permissions* : cocher « Allow
  GitHub Actions to create and approve pull requests », sinon `gh pr create`
  est refusé au jeton du job ;
- les déclencheurs `schedule` ne sont lus que sur la branche par défaut du
  dépôt : tant que `master` ne porte pas ce workflow, seul le lancement
  manuel depuis `develop` fonctionne.

Une PR ouverte par le jeton du job ne déclenche pas `ci.yml`. C'est pourquoi
`submodules-sync` clone lui-même les nouveaux pointeurs avant d'ouvrir la PR,
et met le lien de son run dans la description. Pour obtenir malgré tout le
statut `ci`, fermer et rouvrir la PR.

### Accès de la CI aux submodules

Les quatre dépôts de service sont privés : le `GITHUB_TOKEN` du job ne peut
pas les cloner. Les deux workflows lisent chacun d'eux avec une **clé de déploiement en
lecture seule** (`.github/scripts/submodule-ssh-access.sh`), dont la partie privée est un secret Actions du dépôt
`enervision` :

| Submodule   | Clé de déploiement posée sur | Secret Actions (sur `enervision`) |
| ----------- | ---------------------------- | --------------------------------- |
| `api`       | `EnerVision-G5/api`          | `SUBMODULE_SSH_KEY_API`           |
| `dashboard` | `EnerVision-G5/dashboard`    | `SUBMODULE_SSH_KEY_DASHBOARD`     |
| `predict`   | `EnerVision-G5/predict`      | `SUBMODULE_SSH_KEY_PREDICT`       |
| `infra`     | `EnerVision-G5/infra`        | `SUBMODULE_SSH_KEY_INFRA`         |

Une clé par dépôt, parce que GitHub n'accepte une même clé de déploiement que
sur un seul dépôt. Une clé de déploiement plutôt qu'un jeton personnel : elle
n'est liée à aucun compte et survit au départ d'un membre. Le workflow
n'accorde à son jeton que `contents: read` ; les clés ne servent qu'à lire.

Pour (re)générer les quatre clés, depuis un poste avec droits d'administration
sur les cinq dépôts :

```bash
for r in api dashboard predict infra; do
  ssh-keygen -t ed25519 -N '' -C "enervision-ci submodule $r (lecture seule)" -f "./submodule-$r"
  gh repo deploy-key add "./submodule-$r.pub" -R "EnerVision-G5/$r" \
    -t "enervision-ci submodules (lecture seule)"
  gh secret set "SUBMODULE_SSH_KEY_$(echo "$r" | tr a-z A-Z)" \
    -R EnerVision-G5/enervision < "./submodule-$r"
  rm -P "./submodule-$r" "./submodule-$r.pub"
done
```

`gh repo deploy-key add` pose la clé en lecture seule (l'écriture exige `-w`).
Les fichiers privés ne servent qu'à alimenter les secrets : ils sont supprimés
aussitôt, la CI est leur seul porteur. Une clé compromise se révoque dans
*Settings → Deploy keys* du dépôt concerné, puis se régénère par la boucle
ci-dessus.

## Documentation

`docs/` archive les briefs d'exécution des tickets structurants, par exemple
`docs/EV-06-contrats-openapi.md`.
