#!/usr/bin/env bash
# Sync NixOS ACME wildcard certs into per-namespace cluster TLS secrets.
#
# Env: NAMESPACES (space-separated, required), DOMAINS (default:
#        "diekvoss.net toyvo.dev"), CERT_BASE (default /var/lib/acme),
#        DRY_RUN=1 prints the kubectl invocations instead of applying.
# A TLS Secret holds exactly one cert, so each domain gets its own
# `wildcard-tls-<domain-with-dashes>` secret per namespace.
set -euo pipefail

namespaces="${NAMESPACES:?NAMESPACES is required (space-separated list)}"
domains="${DOMAINS:-diekvoss.net toyvo.dev}"
certBase="${CERT_BASE:-/var/lib/acme}"

# shellcheck disable=SC2086
for domain in $domains; do
  secret="wildcard-tls-${domain//./-}"
  cert="$certBase/$domain/cert.pem"
  key="$certBase/$domain/key.pem"
  if [ ! -f "$cert" ] || [ ! -f "$key" ]; then
    echo "missing cert files for $domain ($cert, $key); skipping" >&2
    continue
  fi
  # shellcheck disable=SC2086
  for ns in $namespaces; do
    if [ "${DRY_RUN:-0}" = "1" ]; then
      echo "k3s kubectl -n $ns create secret tls $secret --cert=$cert --key=$key --dry-run=client -o yaml | k3s kubectl apply -f -"
    else
      k3s kubectl -n "$ns" create secret tls "$secret" \
        --cert="$cert" --key="$key" \
        --dry-run=client -o yaml | k3s kubectl apply -f -
    fi
  done
done
