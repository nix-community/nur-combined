# homepage secrets via SecretSpec Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Homepage widgets get their 17 secret values from Proton Pass into the cluster via SecretSpec, with zero app-side change.

**Architecture:** New static `k8s/homepage/secretspec.toml` contract (project `homepage`, pass+kube providers, full `HOMEPAGE_VAR_*` keys, no `ref`; one `envFrom` addition to the nix-generated Deployment; user-run populate loop; no in-cluster components.

**Tech Stack:** SecretSpec (≥0.20, kubernetes feature) + pass-cli (pinned), `k8s+secret://` provider URIs, k3s auto-deploy manifests.

**Spec:** `docs/superpowers/specs/2026-10-26-homepage-secretspec-design.md`

## Global Constraints

- The toml holds names + descriptions ONLY — never values. Grep-verify before commit.
- Cluster entry names MUST equal the `HOMEPAGE_VAR_*` names (app ignores anything else).
- Pass-side convention: note items titled `homepage/default/<KEY>` in the `secretspec` vault (user's housekeeping, provider default).
- Deployment change is additive (`envFrom` alongside existing file mounts + literal env).
- `nix fmt` before commit; validation is eval + nas toplevel build; populate/verify steps are manual (need user credentials).

## Review Focus

- Wrong key name (typo vs services.yaml widget vars) — expect `diff` of toml key list vs widget `key:`/`password:` vars in the rendered ConfigMap to be empty; test in Task 1 pins it.
- Values accidentally committed — expect `rg -i "password|token|key.*=.*[A-Za-z0-9]{8}"` on the toml to show only descriptions; test in Task 1 pins it.
- envFrom pointing at wrong Secret name — expect rendered manifest `secretRef.name == homepage-widgets` matching the kube provider URI object; test in Task 2 pins it.
- Widgets still erroring after populate (stale pods: envFrom is immutable-without-restart... actually envFrom updates need pod restart) — expect rollout restart after Secret creation; test in Task 3 pins it (delete pods or wait for redeploy).
- Version gate missed (secretspec <0.20 / pass-cli untested combo) — expect `secretspec --version` + `pass-cli` version recorded before populate; test in Task 3 pins it.

---

### Task 1: `k8s/homepage/secretspec.toml` contract

**Files:**
- Create: `k8s/homepage/secretspec.toml`

**Interfaces:**
- Consumes: key list from the rendered `services.yaml` widget blocks; descriptions from root `secretspec.toml` (+3 new in same style).
- Produces: the 17-key contract the populate loop and reviewer check against.

- [ ] **Step 1: Write the file**

  `[project] name = "homepage"`, `[providers] pass = "protonpass://secretspec"`, `kube = "k8s+secret://homepage-widgets"`, `[profiles.default]` with all 17 full `HOMEPAGE_VAR_*` keys (same list, prefixed). Each: `description` (root-catalog wording; 3 new ones noted in spec), `providers = ["pass", "kube"]`, NO ref field. The populate loop maps bare Pass names to full keys explicitly (`HOMEPAGE_VAR_$short`).

- [ ] **Step 2: Verify key list matches widgets**

  Run: `diff <(sorted key list from toml) <(sorted HOMEPAGE_VAR_* from rendered services.yaml)` — expect empty. (Extract services.yaml keys via the nas config eval used in the design check.)

- [ ] **Step 3: Verify no values**

  Run: `rg -iE "password\s*=|token\s*=|key\s*=\s*\"[A-Za-z0-9+/=]{12,}" k8s/homepage/secretspec.toml` — expect matches only in `description` strings, none as values.

- [ ] **Step 4: Commit**

```bash
nix fmt
git add k8s/homepage/secretspec.toml
git commit -m "feat: secretspec contract for homepage widget keys"
```

### Task 2: Deployment `envFrom` wiring

**Files:**
- Modify: `modules/nixos/k3s-homepage.nix`

**Interfaces:**
- Consumes: Secret name `homepage-widgets` (must match kube provider URI object).
- Produces: Deployment with `envFrom: [{secretRef: {name: homepage-widgets}}]` on both servers (identical generation as today).

- [ ] **Step 1: Add envFrom to the container spec**

  In the Deployment's container (alongside `env` with HOMEPAGE_ALLOWED_HOSTS): add `envFrom = [ { secretRef.name = "homepage-widgets"; } ];`. Keep everything else identical. Note: Secret need not exist for the manifest to apply (pods will wait/CrashLoop until populated — expected pre-populate state, resolved in Task 3).

- [ ] **Step 2: Verify rendered manifest + build**

  Run: `nix build ...nas toplevel...` then render/check the deployment yaml contains `secretRef: {name: homepage-widgets}` and nothing else changed (diff containers sans envFrom → empty).
  Expected: PASS.

- [ ] **Step 3: Commit**

```bash
nix fmt
git add modules/nixos/k3s-homepage.nix
git commit -m "feat: homepage reads widget secrets from cluster Secret"
```

### Task 3: Manual populate + verify (user)

**Files:** none (commands run by user with their credentials).

- [ ] **Step 1: Version gates**

  Run: `secretspec --version` (expect ≥0.20, kubernetes feature) and note `pass-cli` version (must be a tested one per the docs warning).
  Expected: recorded; abort here if gates fail.

- [ ] **Step 2: Ensure Pass-side items exist**

  In Proton Pass `secretspec` vault: note items titled `homepage/default/<KEY>` for all 17 keys (copy from wherever they live today).

- [ ] **Step 3: Populate the cluster Secret**

  Run from `k8s/homepage`: populate loop (`secretspec set <KEY> --provider k8s+secret://homepage-widgets` per key, values resolving via the pass provider; confirm non-interactive piping vs 17 prompts on first key and proceed accordingly). Then: `sudo k3s kubectl get secret homepage-widgets -o jsonpath='{.data}' | python3 -c json keys` — expect exactly the 17 plain key names.

- [ ] **Step 4: Roll + verify widgets**

  Restart pods to pick up the new env (`sudo k3s kubectl rollout restart deploy/homepage` or delete pods), then load `https://diekvoss.net` with auth: widgets render data, `kubectl logs deploy/homepage` shows no secret errors.

### Task 4: Docs + housekeeping

**Files:**
- Modify: `todos.md`

- [ ] **Step 1: Update todos, format**

  Check off homepage-secrets; add follow-ups (pkgs/pass-cli pin, Nix-side secretspec consumption decision, pattern reuse for next service). Run `nix fmt && nix flake show`.
  Expected: PASS.

- [ ] **Step 2: Commit**

```bash
git add todos.md docs/superpowers/plans/2026-10-26-homepage-secretspec.md
git commit -m "docs: homepage secrets via secretspec complete"
```
