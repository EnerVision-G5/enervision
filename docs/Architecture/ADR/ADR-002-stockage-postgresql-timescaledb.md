# ADR-002 : Stockage PostgreSQL + TimescaleDB

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F3 |

## Contexte

Les mesures de consommation arrivent au rythme d'un point par minute et par
site (ADR-005) et doivent être conservées pour l'historique, l'entraînement
du modèle et l'affichage du dashboard. Il faut donc un stockage de séries
temporelles capable de servir des agrégats sur de longues plages, tout en
portant aussi les données métier (sites, utilisateurs, alertes).

## Options étudiées

- **Option A — PostgreSQL seul**
  - avantages : un seul moteur, compétences déjà présentes, SQL standard.
  - inconvénients : pas de partitionnement temporel natif, agrégats longs
    coûteux quand le volume croît.
- **Option B — Base time-series dédiée (InfluxDB)**
  - avantages : optimisée pour les séries, rétention et downsampling natifs.
  - inconvénients : deuxième moteur à exploiter à côté du relationnel,
    langage de requête spécifique, jointures métier difficiles.
- **Option C — PostgreSQL + extension TimescaleDB**
  - avantages : hypertables et agrégats continus, compression et rétention
    natives, SQL standard et jointures avec les tables métier.
  - inconvénients : extension supplémentaire à installer et à maintenir sur
    le serveur on-premise.

## Décision

PostgreSQL avec l'extension TimescaleDB : un seul moteur pour les séries et
le métier, sans renoncer aux performances sur les requêtes temporelles.

## Conséquences

L'extension doit être installée et versionnée dans le provisioning
on-premise (ADR-011) ; les politiques de rétention et de compression sont à
définir explicitement ; la table de mesures est une hypertable, ce qui
contraint la forme de la clé primaire (la colonne de temps doit en faire
partie).

À réexaminer si la volumétrie dépasse ce qu'un serveur unique absorbe, ou
si un besoin de cloisonnement multi-tenant strict apparaît.

## Amendements

—
