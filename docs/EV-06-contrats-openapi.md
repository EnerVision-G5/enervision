# EV-06 — Contrats OpenAPI gelés entre api, dashboard et predict

> Brief d'exécution archivé tel que reçu. Il documente l'intention du ticket.
> La référence vivante du contrat est `docs/contracts/`.

## 1. Mission

Produire le contrat d'interface entre les trois services du projet EnerVision, sous forme de DTO Pydantic qui génèrent la spécification OpenAPI, geler cette spécification dans le repo `enervision`, générer les types TypeScript du dashboard à partir d'elle, et installer une garde CI qui fait échouer le build en cas de dérive entre le code et le contrat gelé.

Ce ticket ne contient AUCUNE logique métier. Les endpoints sont des squelettes (stubs) qui déclarent leurs modèles d'entrée et de sortie. L'implémentation réelle relève d'autres tickets (EV-11 lecture des mesures, EV-12 auth JWT, EV-20+ prédiction). Si tu es tenté d'implémenter une requête SQL ou un vrai flux d'authentification, arrête-toi : ce n'est pas le périmètre.

## 2. Contexte projet

- Plateforme : Smart Energy Optimizer (EnerVision). Ingestion de mesures énergétiques de 7 sites depuis une API Mock IoT, stockage TimescaleDB on-premise, API métier FastAPI, dashboard React, modèle de prédiction XGBoost servi par un endpoint d'inférence séparé (déployé sur Azure).
- Stack actée : FastAPI + Pydantic v2 (Python 3.11+), React + TypeScript (Vite), XGBoost + MLflow.
- Arborescence : un repo `enervision` qui référence en submodules Git les repos `api`, `dashboard`, `predict`, `infra`. Tu travailles dans `api`, `predict`, `dashboard` et `enervision`.
- Convention de branche : `EADL_2026_NANTES_G5/EV-06-contrats-openapi` dans chaque repo touché. Une PR par repo, pas de push direct sur develop.
- Deux back-ends distincts à contractualiser :
  - l'API métier (repo `api`), on-premise, qui sert sites, mesures et alertes sous JWT,
  - le service d'inférence (repo `predict`), sur Azure, qui sert uniquement les prédictions.

## 3. Conventions transverses (à respecter partout)

- Préfixe de routes : `/api/v1`.
- Noms de champs : en anglais, identiques à ceux de l'API Mock source (`consumption_kw`, `data_quality`, `null_reasons`...) pour que l'ETL ne fasse aucun renommage. Ne francise aucun champ.
- Dates : ISO 8601, type `datetime`, UTC.
- Toute réponse d'erreur suit le modèle `ErrorResponse` défini ci-dessous. Documente explicitement les codes 401, 404 et 422 sur chaque endpoint concerné (paramètre `responses` de FastAPI).
- Pydantic v2 : utilise `model_config = ConfigDict(from_attributes=True)` sur les DTO de sortie, des `Field(description=...)` sur chaque champ (ces descriptions alimentent la doc Swagger), et des `Literal`/`Enum` pour les valeurs fermées.
- Chaque module de schémas contient un commentaire d'en-tête : "Source de vérité du contrat. Toute modification exige une PR sur enervision/docs/contracts et la relecture des trois consommateurs."

## 4. Phase A — Repo `api` : DTO et squelette de l'API métier

### 4.1 Modèles partagés (`app/schemas/common.py`)

```
DataQuality = Literal["good", "partial", "degraded", "critical"]

ErrorResponse:
  detail: str

PaginationMeta:
  total: int          # nombre total d'éléments
  limit: int          # taille de page demandée (1 à 1000, défaut 100)
  offset: int         # décalage
```

### 4.2 DTO métier (`app/schemas/energy.py`)

`SiteOut` (miroir du site de l'API Mock) :
- site_id: str, site_type: str, site_name: str, location: str, capacity_kw: float, status: str

`EnergyReadingOut` (miroir exact de l'EnergyReading source, PLUS les colonnes d'imputation de notre base) :
- timestamp: datetime
- site_id: str
- site_type: str
- consumption_kw: float | None
- consumption_kwh: float | None
- voltage_v: float | None
- current_a: float | None
- power_factor: float | None
- temperature_celsius: float | None
- humidity_percent: float | None
- null_reasons: list[str]
- data_quality: DataQuality
- consumption_kw_imputed: float | None   # valeur imputée, jamais confondue avec la brute
- imputation_method: Literal["none", "locf", "interpolation"]

`ReadingsPage` :
- items: list[EnergyReadingOut]
- meta: PaginationMeta

`AlertOut` (miroir de l'alerte Mock) :
- alert_id: str, timestamp: datetime, site_id: str
- severity: Literal["low", "medium", "high", "critical"]
- type: Literal["spike", "threshold", "anomaly", "outage", "sensor"]
- message: str, value: float, threshold: float

### 4.3 DTO auth (`app/schemas/auth.py`)

- `TokenResponse` : access_token: str, token_type: Literal["bearer"], expires_in: int
- `UserOut` : username: str, role: Literal["reader", "writer"]

### 4.4 Endpoints à déclarer (stubs levant `HTTPException(501)` ou renvoyant un exemple statique)

| Méthode | Route | Response model | Erreurs documentées |
|---|---|---|---|
| GET | /api/v1/health | dict {status, timestamp} | — |
| POST | /api/v1/auth/token | TokenResponse | 401 |
| GET | /api/v1/sites | list[SiteOut] | 401 |
| GET | /api/v1/sites/{site_id} | SiteOut | 401, 404 |
| GET | /api/v1/sites/{site_id}/readings | ReadingsPage | 401, 404, 422 |
| GET | /api/v1/sites/{site_id}/readings/latest | EnergyReadingOut | 401, 404 |
| GET | /api/v1/alerts | list[AlertOut] | 401, 422 |

Paramètres de `/readings` : `start_time: datetime`, `end_time: datetime`, `limit: int = 100 (1 à 1000)`, `offset: int = 0`. Paramètres de `/alerts` : `site_id: str | None`, `severity: str | None` (validée contre l'énum).

Le POST /auth/token est déclaré avec `OAuth2PasswordRequestForm` pour que le flux OAuth2 password apparaisse dans la spec, mais renvoie 501 : l'implémentation est EV-12.

### 4.5 Export du contrat (`scripts/export_openapi.py`)

Script qui importe l'app FastAPI, appelle `app.openapi()`, force `info.version` depuis une constante `CONTRACT_VERSION = "1.0.0"` dans `app/main.py`, et écrit le JSON trié (`json.dumps(..., indent=2, sort_keys=True)`) sur stdout ou dans le fichier passé en argument. Le tri des clés est obligatoire, c'est ce qui rend la comparaison CI déterministe.

### Point de vérification A

`uvicorn app.main:app` démarre, `/docs` liste les 7 routes avec leurs modèles, `python scripts/export_openapi.py` produit un JSON valide.

## 5. Phase B — Repo `predict` : contrat du service d'inférence

Service FastAPI minimal et séparé (`inference/app.py`) avec ses propres schémas (`inference/schemas.py`) :

`PredictionRequest` :
- site_id: str
- horizon_hours: int (1 à 48, défaut 24)

`PredictionPoint` :
- timestamp: datetime
- predicted_consumption_kw: float
- lower_bound_kw: float | None
- upper_bound_kw: float | None

`PredictionOut` :
- site_id: str
- model_version: str          # tag MLflow du modèle servant la réponse
- generated_at: datetime
- points: list[PredictionPoint]

Endpoints : `GET /health` et `POST /api/v1/predict` (response model PredictionOut, erreurs 404 site inconnu et 422). Stub 501 identique. Même script d'export (`scripts/export_openapi.py`), même constante `CONTRACT_VERSION`.

### Point de vérification B

Le service démarre, l'export produit un JSON valide contenant PredictionOut.

## 6. Phase C — Repo `enervision` : gel des contrats

Créer `docs/contracts/` contenant :
- `openapi-api.json` — export de la phase A
- `openapi-predict.json` — export de la phase B
- `README.md` — la règle de gouvernance, en français, sans tiret cadratin ni point-virgule : ces deux fichiers font foi entre les équipes, toute évolution passe par une PR modifiant le fichier gelé, relue par un représentant de chaque consommateur (api, dashboard, predict), et le numéro CONTRACT_VERSION est incrémenté en semver (patch : description, minor : champ optionnel ajouté, major : champ retiré ou renommé). Mentionner que la CI de chaque service compare le code au fichier gelé.

### Point de vérification C

Les deux JSON sont committés et le README explique la procédure de modification en moins d'une page.

## 7. Phase D — Repo `dashboard` : génération des types

- Ajouter `openapi-typescript` en devDependency.
- Scripts npm :
  - `"gen:types": "openapi-typescript ../enervision/docs/contracts/openapi-api.json -o src/types/api.d.ts && openapi-typescript ../enervision/docs/contracts/openapi-predict.json -o src/types/predict.d.ts"`
  - Adapter le chemin relatif à la position réelle du submodule. Si le dashboard est cloné isolément, prévoir une variable d'environnement CONTRACTS_DIR avec ce chemin par défaut.
- Générer les types une première fois et committer `src/types/*.d.ts`.
- Ajouter dans le README du dashboard : "Ne jamais éditer src/types à la main, toujours regénérer via npm run gen:types après une évolution de contrat."

### Point de vérification D

`npm run gen:types` passe, `tsc --noEmit` passe, les types EnergyReadingOut et PredictionOut existent dans les fichiers générés.

## 8. Phase E — Garde CI anti-dérive (repos `api` et `predict`)

Ajouter à chaque pipeline GitHub Actions un job `contract-drift` :

```yaml
contract-drift:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with: { python-version: "3.11" }
    - run: pip install -r requirements.txt
    - name: Récupérer le contrat gelé
      uses: actions/checkout@v4
      with:
        repository: EnerVision-G5/enervision
        path: enervision
        token: ${{ secrets.CONTRACTS_READ_TOKEN }}
    - name: Comparer le code au contrat gelé
      run: |
        python scripts/export_openapi.py > /tmp/openapi-current.json
        diff -u enervision/docs/contracts/openapi-api.json /tmp/openapi-current.json \
          || { echo "::error::Le code a dérivé du contrat gelé. Ouvrir une PR sur enervision/docs/contracts ou corriger le code."; exit 1; }
```

Adapter le nom du fichier (`openapi-predict.json`) côté predict. Si l'org permet la lecture inter-repos avec le GITHUB_TOKEN par défaut, supprimer le token dédié et le noter dans la PR. Le message d'erreur doit dire explicitement les deux issues possibles : PR sur le contrat ou correction du code.

### Point de vérification E

Sur une branche de test, modifier un champ d'un DTO fait échouer le job avec le message attendu, le remettre le fait passer au vert.

## 9. Livraison — une seule PR, sur le repo enervision

Le point de revue unique de ce ticket est une PR sur `enervision`, titre `EV-06 · Contrats OpenAPI gelés`. Procédure :

1. Dans `api`, `predict` et `dashboard` : commits sur la branche `EADL_2026_NANTES_G5/EV-06-contrats-openapi`, push, puis merge dans `develop` sans revue individuelle (si la protection de branche exige une PR, ouvre une PR technique et merge-la immédiatement en la marquant "revue portée par la PR enervision EV-06").
2. Dans `enervision` : même branche, qui contient les contrats gelés (`docs/contracts/`), ce brief archivé dans `docs/`, et la mise à jour des pointeurs de submodules vers les commits mergés des trois repos.
3. Ouvre LA PR sur `enervision`. Sa description liste les fichiers créés par repo, les points de vérification passés, et le lien du run CI du test de dérive. C'est cette PR que l'équipe relit : le diff des pointeurs de submodules permet de naviguer vers chaque changement.
4. Ne merge pas cette PR toi-même : la relecture par les trois consommateurs (api, dashboard, predict) vaut gel initial du contrat en version 1.0.0.

## 10. Critères d'acceptation finaux (reprendre dans la PR)

1. Les deux openapi.json gelés existent dans enervision/docs/contracts avec le README de gouvernance.
2. Les DTO couvrent tous les champs de l'EnergyReading source plus les colonnes d'imputation, sans renommage.
3. Les types TypeScript sont générés depuis les contrats, jamais écrits à la main.
4. Le job contract-drift échoue sur une dérive volontaire et passe une fois la dérive corrigée (capture d'écran ou lien de run dans la PR enervision).
5. Aucune logique métier implémentée : tous les endpoints non triviaux renvoient 501.
