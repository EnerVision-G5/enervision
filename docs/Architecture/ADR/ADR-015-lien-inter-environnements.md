# ADR-015 : Lien inter-environnements (VPN / passerelle TLS)

| Champ | Valeur |
| --- | --- |
| Date | — (décision reportée à J4) |
| Auteur | Équipe G5 (atelier de décision d'architecture), responsable GL |
| Statut | Sans objet — remplacé par ADR-017 |
| Exigences liées | NF1, NF9 |

## Contexte

L'architecture hybride (ADR-001) impose des échanges entre le on-premise et
Azure : promotion des artefacts de modèle (ADR-003) et accès de l'API aux
données de référence. Ce lien traverse Internet et transporte des éléments
liés à des données sensibles : il doit être chiffré, authentifié des deux
côtés et exposer la plus petite surface possible.

## Options étudiées

- **Option A — Tunnel VPN site à site**
  - avantages : les deux réseaux se voient, chiffrement au niveau réseau,
    rien à réécrire côté applicatif.
  - inconvénients : surface réseau plus large qu'un seul service, mise en
    place et exploitation plus lourdes.
- **Option B — Passerelle TLS applicative (mTLS)**
  - avantages : surface réduite aux seuls points d'échange exposés,
    authentification mutuelle par certificat, mise en place plus simple.
  - inconvénients : chaque flux doit être exposé explicitement, gestion du
    cycle de vie des certificats à notre charge.

## Décision

Non tranchée. Décision reportée à J4, responsable GL, après prototype VPN ;
la passerelle TLS reste l'option de repli si le VPN s'avère trop lourd.

## Conséquences

À compléter une fois la décision prise. Tant que l'arbitrage n'est pas
rendu, le pipeline de promotion des artefacts (ADR-003) et les échanges
inter-environnements restent en attente de leur transport définitif.

## Amendements

02/09/2026 — décision d'architecture V2 — jamais tranché, devenu sans objet et remplacé par [ADR-017](ADR-017-pivot-tout-on-premise.md) : il n'y a plus qu'un environnement, donc plus de lien à sécuriser.
