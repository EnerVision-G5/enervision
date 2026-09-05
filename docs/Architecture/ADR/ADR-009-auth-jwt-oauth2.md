# ADR-009 : Authentification JWT via OAuth2

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Accepté — amendé par ADR-017 |
| Exigences liées | F6, NF1 |

## Contexte

L'API est publique (ADR-004) et sert des données de consommation par site :
chaque appel doit être authentifié et rattaché à un utilisateur. Le client
est une application statique hébergée sur une origine différente de l'API,
ce qui exclut un modèle de session strictement lié au serveur qui rend les
pages.

## Options étudiées

- **Option A — Session serveur avec cookie**
  - avantages : révocation immédiate, jeton opaque côté client.
  - inconvénients : état partagé côté serveur, cookies inter-origines à
    configurer finement, mal adapté à un front statique distant.
- **Option B — OAuth2 password flow avec jetons JWT**
  - avantages : sans état côté serveur, support natif dans FastAPI
    (ADR-007), transport par en-tête indépendant des contraintes de cookie,
    portée exprimable dans le jeton.
  - inconvénients : révocation avant expiration difficile, la durée de vie
    doit rester courte, clé de signature à protéger.
- **Option C — Fournisseur d'identité externe (Entra ID)**
  - avantages : SSO d'entreprise, MFA, gestion des comptes déléguée.
  - inconvénients : dépendance et configuration hors du périmètre du
    projet, inutile pour la base d'utilisateurs visée.

## Décision

OAuth2 (flux mot de passe) délivrant des JWT signés, vérifiés par l'API à
chaque requête : authentification sans état, adaptée à un front statique
sur une autre origine.

## Conséquences

La clé de signature est un secret géré par Key Vault (ADR-013) ; les jetons
ont une durée de vie courte, avec un rafraîchissement explicite côté front ;
la révocation immédiate n'est pas possible sans liste de rejet, ce qui est
accepté à ce stade ; les mots de passe sont stockés hachés.

À réexaminer si un SSO d'entreprise est exigé ou si la révocation immédiate
devient nécessaire.

## Amendements

02/09/2026 — décision d'architecture V2 ([ADR-017](ADR-017-pivot-tout-on-premise.md)) — la décision est inchangée ; la clé de signature vient du vault Ansible chiffré et non de Key Vault (ADR-013 remplacé). Le dashboard reste sur une autre origine que l'API, servie par Traefik.
