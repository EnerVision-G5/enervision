# ADR-004 : Dashboard sur Azure Static Web Apps

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté |
| Exigences liées | F7 |

## Contexte

Le dashboard est une application front qui ne consomme que l'API REST
(ADR-007) et n'accède jamais directement à la base. Il doit être exposé
publiquement en HTTPS, sans que cette exposition passe par le serveur
on-premise qui héberge la donnée brute (ADR-001).

## Options étudiées

- **Option A — Azure Static Web Apps**
  - avantages : hébergement statique managé, HTTPS et certificats
    automatiques, distribution CDN, intégration native avec la CI GitHub,
    coût très faible.
  - inconvénients : pas de rendu serveur, contraint à une application
    purement statique.
- **Option B — Azure App Service**
  - avantages : rendu serveur possible, plus de latitude d'exécution.
  - inconvénients : coût et exploitation superflus pour du contenu statique.
- **Option C — Serveur web on-premise (Nginx)**
  - avantages : aucune dépendance cloud supplémentaire.
  - inconvénients : ouvre sur l'extérieur le serveur qui porte la donnée,
    TLS et disponibilité à notre charge.

## Décision

Azure Static Web Apps : l'exposition publique est portée par un service
managé, physiquement séparée de la donnée brute, pour un coût et une charge
d'exploitation minimes.

## Conséquences

Le front doit rester une SPA livrée en artefacts statiques (ADR-008) ; les
appels à l'API traversent deux origines, donc CORS et transport du jeton
(ADR-009) doivent être configurés explicitement ; le déploiement est
déclenché par la CI du repo `dashboard`.

À réexaminer si un rendu serveur ou des contraintes de référencement
apparaissent.

## Amendements

—
