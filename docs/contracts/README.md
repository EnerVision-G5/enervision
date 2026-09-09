# Contrats OpenAPI gelés

Ce dossier contient les deux spécifications qui font foi entre les équipes EnerVision.

| Fichier | Service | Repo générateur | Commande d'export |
|---|---|---|---|
| `openapi-api.json` | API métier on-premise | `api` | `python scripts/export_openapi.py ../docs/contracts/openapi-api.json` |
| `openapi-predict.json` | Service d'inférence on-premise, appelé par la seule API métier | `predict` | `python scripts/export_openapi.py ../docs/contracts/openapi-predict.json` |

Ces deux fichiers sont la référence commune de `api`, `dashboard` et `predict`.
Aucune équipe ne code contre une autre source.

## Qui produit quoi

Les fichiers ne sont jamais écrits à la main. Ils sont générés à partir des DTO
Pydantic de chaque service, seuls porteurs de la vérité du contrat.

Le dashboard ne lit pas non plus ces fichiers à la main. Il en dérive ses types
TypeScript avec `npm run gen:types`, et les fichiers de `dashboard/src/types`
sont eux aussi générés.

## Procédure de modification

1. Modifier le DTO Pydantic dans le repo concerné, sur une branche dédiée.
2. Régénérer le fichier gelé avec la commande d'export du tableau ci-dessus.
3. Incrémenter `CONTRACT_VERSION` dans `app/main.py` côté `api` ou
   `services/serving/src/serving/api.py` côté `predict`, en suivant la règle
   semver ci-dessous.
4. Régénérer le fichier gelé une seconde fois pour que la nouvelle version
   apparaisse dans `info.version`.
5. Ouvrir une PR sur ce repo `enervision` contenant le diff du fichier gelé.
6. Faire relire cette PR par un représentant de chacun des trois consommateurs,
   `api`, `dashboard` et `predict`. Les trois accords valent gel de la nouvelle
   version.
7. Une fois la PR fusionnée, régénérer les types du dashboard avec
   `npm run gen:types` et committer le résultat.

## Règle de version

`CONTRACT_VERSION` suit le semver.

- **patch** pour une modification qui ne change aucune forme de donnée, par
  exemple une description de champ ou un résumé d'endpoint.
- **minor** pour un ajout rétrocompatible, par exemple un champ optionnel, un
  endpoint supplémentaire ou une nouvelle valeur d'énumération en sortie.
- **major** pour toute rupture, par exemple un champ retiré, un champ renommé,
  un champ optionnel devenu obligatoire ou un type modifié.

La version initiale est `1.0.0`. Elle est figée par la relecture croisée des
trois consommateurs.

## Contrôle automatique de dérive

La CI de `api` et celle de `predict` exécutent un job `contract-drift` à chaque
push et à chaque PR. Ce job récupère ce repo, régénère la spécification depuis
le code du service, et la compare au fichier gelé correspondant.

Un écart fait échouer le build. Deux issues seulement sont possibles.

- L'évolution est voulue. Il faut ouvrir une PR ici, sur le fichier gelé, en
  suivant la procédure ci-dessus.
- L'évolution est accidentelle. Il faut corriger le code du service pour
  revenir au contrat.

La comparaison porte sur un JSON à clés triées, produit par
`json.dumps(..., indent=2, sort_keys=True)`. Ce tri est ce qui rend le diff
stable. Les versions de FastAPI et de Pydantic sont épinglées dans les
`requirements.txt` des deux services, pour la même raison. Une montée de
version de ces bibliothèques peut modifier la spécification générée, elle passe
donc elle aussi par une PR de contrat.
