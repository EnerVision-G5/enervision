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

Cloner avec les submodules :

```bash
git clone --recurse-submodules https://github.com/EnerVision-G5/enervision.git
```

Sur un clone déjà présent :

```bash
git submodule update --init --recursive
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

`.github/workflows/ci.yml` s'exécute à chaque push et sur chaque pull request
(critère EV-02) :

- checkout avec `submodules: recursive` pour voir l'arborescence complète ;
- `git submodule status --recursive` pour tracer les pointeurs ;
- lint de la documentation Markdown du repo parent (`markdownlint-cli2`).

Un document Markdown non conforme fait échouer la PR. Chaque submodule porte en
plus son propre pipeline lint / tests / build, avec un badge de statut dans son
README.

## Documentation

`docs/` archive les briefs d'exécution des tickets structurants, par exemple
`docs/EV-06-contrats-openapi.md`.
