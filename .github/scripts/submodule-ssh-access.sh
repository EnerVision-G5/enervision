#!/usr/bin/env bash
#
# Donne au job un accès SSH en lecture aux quatre submodules privés.
#
# Attend, en variables d'environnement, la clé privée de déploiement de chaque
# dépôt : SUBMODULE_SSH_KEY_API, _DASHBOARD, _PREDICT, _INFRA. Une clé par
# dépôt, car GitHub n'accepte une même clé de déploiement que sur un seul.
# Chaque clé est rattachée à un alias SSH, et l'URL https du .gitmodules est
# réécrite vers cet alias : les développeurs gardent le clone https.

set -euo pipefail
umask 077
mkdir -p ~/.ssh

# Clé d'hôte publiée par GitHub (docs.github.com, « GitHub's SSH key
# fingerprints »), figée plutôt qu'apprise au premier contact.
echo 'github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl' >> ~/.ssh/known_hosts

missing=0
for name in api dashboard predict infra; do
  var="SUBMODULE_SSH_KEY_$(printf '%s' "$name" | tr a-z A-Z)"
  if [ -z "${!var:-}" ]; then
    echo "::error::Secret $var absent : clé de déploiement en lecture du dépôt $name (voir README, Intégration continue)."
    missing=1
    continue
  fi
  printf '%s\n' "${!var}" > ~/.ssh/submodule-"$name"
  cat >> ~/.ssh/config <<CONF
Host github-$name
  HostName github.com
  User git
  IdentityFile ~/.ssh/submodule-$name
  IdentitiesOnly yes
CONF
  git config --global "url.git@github-$name:EnerVision-G5/$name.git.insteadOf" \
    "https://github.com/EnerVision-G5/$name.git"
done
test "$missing" = 0
