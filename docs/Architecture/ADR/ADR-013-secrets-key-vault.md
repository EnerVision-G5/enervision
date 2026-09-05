# ADR-013 : Secrets — Azure Key Vault + fichiers env hors Git

| Champ | Valeur |
| --- | --- |
| Date | 31/08/2026 |
| Auteur | Équipe G5 (atelier de décision d'architecture) |
| Statut | Remplacé par ADR-017 |
| Exigences liées | NF1 |

## Contexte

Plusieurs secrets circulent entre les deux environnements (ADR-001) :
identifiants de base, clé de signature des jetons (ADR-009), accès à la
source de mesures, identifiants de déploiement. Ils sont partagés par
plusieurs repos (ADR-014) et ne doivent jamais entrer dans l'historique
Git, où ils resteraient même après suppression.

## Options étudiées

- **Option A — Variables de secrets du système de CI uniquement**
  - avantages : disponible sans infrastructure supplémentaire.
  - inconvénients : rien pour l'exécution hors CI, duplication d'un repo à
    l'autre, rotation manuelle et dispersée.
- **Option B — Azure Key Vault, plus fichiers d'environnement locaux
  exclus de Git**
  - avantages : dépôt unique et audité pour les secrets partagés, accès par
    identité managée sans secret intermédiaire, développement local
    possible sans réseau.
  - inconvénients : dépendance à Azure pour un service transverse, gestion
    des droits d'accès à tenir à jour.
- **Option C — HashiCorp Vault auto-hébergé**
  - avantages : indépendant du fournisseur cloud, très complet.
  - inconvénients : service supplémentaire à héberger, sécuriser et
    sauvegarder ; disproportionné à l'échelle du projet.

## Décision

Azure Key Vault comme source de vérité des secrets partagés, consommé par
identité managée ; en local, des fichiers d'environnement exclus de Git,
avec un modèle d'exemple sans valeur réelle versionné à leur place.

## Conséquences

Chaque repo versionne un fichier d'exemple documentant les variables
attendues, et son `.gitignore` exclut le fichier réel ; l'accès au Key
Vault se règle par les droits d'identité, à maintenir dans le code
d'infrastructure (ADR-011) ; le fichier d'état Terraform est traité comme
un élément sensible ; toute fuite constatée impose une rotation, pas une
simple suppression du fichier.

À réexaminer si un environnement doit fonctionner sans dépendance à Azure.

## Amendements

02/09/2026 — décision d'architecture V2 — remplacé par [ADR-017](ADR-017-pivot-tout-on-premise.md) : Key Vault est retiré ; les secrets partagés vivent dans un vault Ansible chiffré versionné, les fichiers d'environnement hors Git sont déployés par Ansible, ceux de la CI dans GitHub Actions. La règle « fichier d'exemple versionné, réel ignoré, rotation en cas de fuite » reste.
