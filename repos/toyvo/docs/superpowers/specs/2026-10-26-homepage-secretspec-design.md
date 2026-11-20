# homepage secrets via SecretSpec (Proton Pass → k8s) — Short Design

Date: 2026-10-26
Status: proposed, awaiting approval
Approach picked: secretspec as contract + delivery (k8s provider); no operator.

## Intent / why

Homepage widgets need 17 secret values (`HOMEPAGE_VAR_*`). They live in
Proton Pass today; the cluster has none (widgets error, page renders).
Use SecretSpec — already the repo's catalog direction — as both the
contract and the delivery tool via its Kubernetes provider, instead of
adding Sealed Secrets, ESO, or flux.

## Goals

- New file `k8s/homepage/secretspec.toml`, independent of the repo-root
  catalog: project `homepage`, profile `default`, providers
  `pass = "protonpass://secretspec"` and
  `kube = "k8s+secret://homepage-widgets"` (default namespace, where the
  app lives).
- 17 keys named exactly as the app reads them (`HOMEPAGE_VAR_*`, same
  as the native env file — verified against sops `homepage.env`).
  Pass holds namespaced notes `homepage/default/<KEY>` (verified:
  full-name check passes against protonpass; user requires this layout
  untouched). Each key carries kube-scoped `refs = { kube = { item =
  "<same full name>" } }` — NOT route-wide `ref`, which would also
  redirect Pass reads. Without the kube pin the provider falls back to
  namespaced storage (`secretspec--project--profile--key`), whose
  dashes are invalid in env var names so kubelet silently drops them
  (observed). Verified in provider source: convention compiles to
  namespaced form; Native addresses (ref/refs) pass through verbatim.
  Descriptions mirror the root catalog (3 are new:
  NEXTCLOUD_PASSWORD, TECHNITIUM_USERNAME/PASSWORD — same credentials
  as their ADMIN counterparts under widget-specific names).
- No Pass reorganization needed. Reusable pattern: full-name keys +
  `ref.item` pinning exact entries; `check` validates both sides.
- Deployment gains `envFrom: [ secretRef homepage-widgets ]`
  (nix-generated manifest, identical on all servers).
- Populate/rotate: `secretspec set <KEY> --provider kube` per key;
  `secretspec check` enforces the contract on both providers.

## Non-goals

- No Nix consumption of secretspec (sops stays load-bearing in Nix).
- No other service's keys; no value migration (values already in Pass).
- No Traefik/Caddy changes.

## Anti-goals

- No new in-cluster component (no operator, CRDs, or controller).
- Don't invent key names: cluster entries MUST equal the
  `HOMEPAGE_VAR_*` names or the app ignores them.
- Don't commit values anywhere: the toml holds names + descriptions only.

## Constraints

- secretspec ≥0.20 with the `kubernetes` feature (binary-safe values
  need 0.21+); verify with `secretspec --version` before building on it.
- `pass-cli` pinned + tested per their own warning (breaks on upgrade);
  PAT for anything unattended; `SECRETSPEC_PROTONPASS_CLI_PATH` if
  pinning outside PATH. Eventual home: a pinned `pkgs/pass-cli`
  following the repo's versions.json convention (not this change).
- k8s provider auth = the invoker's kubectl identity.

## Approaches considered

- secretspec k8s provider (picked): no operator, honors the catalog
  direction already underway; full key names match what the app reads.
- Sealed Secrets / ESO / flux (superseded): correct tools in general,
  all heavier than needed now that secretspec reads+writes k8s natively.
- Manual `sops -d | kubectl apply` (rejected): imperative, rots,
  unauditable.

## Decided (what the builder implements)

1. `k8s/homepage/secretspec.toml` as above (17 full-name keys, no ref,
   providers pass+kube).
2. `modules/nixos/k3s-homepage.nix`: add `envFrom: [{ secretRef:
   { name: homepage-widgets } }]` to the Deployment container (keep the
   literal `HOMEPAGE_ALLOWED_HOSTS` env).
3. Runbook (user executes): `pass-cli login` (or PAT),
   populate loop, `kubectl get secret homepage-widgets`,
   `secretspec check`, verify widgets, failover-agnostic (Secret is
   cluster state, survives node loss).

## Left to the builder

- Exact `set`-loop UX: confirm whether values pipe non-interactively or
  the first population is 17 prompts; document what actually works.
- `secretspec --version` gate before relying on provider behavior.

## Builder self-check (no subagent tool)

- Key list cross-checked against the rendered services.yaml widget
  blocks (9 API keys + 2×qbittorrent/nextcloud/omada/technitium user+pass
  = 17; `site` is plaintext config, correctly excluded).
- No values in the toml (names + descriptions only) — verified on write.
- Namespace matches app (default) — no `@namespace` suffix needed.
- Rollback: delete Secret + revert envFrom; page returns to today's
  keyless-but-rendering state.
