# ADR-007 : FastAPI (back-end)

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F6 |

## Contexte

Le back-end expose les mesures, prédictions, alertes et recommandations au
dashboard, qui est le seul client et vit sur une autre origine (ADR-004).
Le contrat d'interface doit être stable et publié tôt, puisque front et
back sont développés en parallèle dans des repos distincts (ADR-014).

## Options étudiées

- **Option A — FastAPI**
  - avantages : schéma OpenAPI généré depuis le code, validation des
    entrées et sorties par Pydantic, ASGI asynchrone, cohérent avec un
    écosystème Python déjà retenu pour l'ETL et le ML.
  - inconvénients : écosystème plus jeune, discipline de typage exigée.
- **Option B — Flask**
  - avantages : très répandu, minimal, grande liberté.
  - inconvénients : validation et documentation à câbler via des extensions,
    contrat plus facilement désynchronisé du code.
- **Option C — Django REST Framework**
  - avantages : cadre complet, ORM, administration, authentification
    intégrée.
  - inconvénients : cadre lourd pour une API de lecture, impose son ORM et
    sa structure.

## Décision

FastAPI : le contrat OpenAPI est produit par le code lui-même, ce qui
supprime l'écart entre la documentation et l'implémentation, et la
validation Pydantic couvre les entrées sans code défensif dispersé.

## Conséquences

Le service tourne derrière un serveur ASGI (uvicorn) ; les modèles Pydantic
deviennent la source de vérité du contrat consommé par le dashboard ; le
schéma OpenAPI est versionné et sert de référence de découplage entre les
repos `api` et `dashboard`.

À réexaminer si le back-end doit porter du rendu serveur ou une
administration complète.

## Amendements

—
