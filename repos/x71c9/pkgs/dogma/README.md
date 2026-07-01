# dogma

Dogma bridges secrets from vault backends and infrastructure outputs into sops-encrypted files, then deploys them to your machines. It also comes with a set of tools — pre-credentialed shells, environment variable exports, and more — to make the whole workflow seamless.

> Crate: `dogma-rust` — Binary: `dogma`

## Quick start

```yaml
# dogma.yml
name: myproject
env: [dev, prod]
admin:
  - gpg: 3246EC6F403D8F3403E34A90BCDABC277B1ED8AB

vault:
  hcloud-token:
    pass: myproject/{env}/hcloud-token
  stripe-webhook-secret:
    pass: myproject/{env}/stripe-webhook-secret

infra:
  credentials:
    TF_VAR_hcloud_token:
      from: vault
      ref: hcloud-token

machines:
  backend:
    hostname: myproject-{env}
    ip: { from: infra, unit: hetzner, output: server_ip }
    secrets: [backend]

secrets:
  backend:
    stripe_webhook_secret: { from: vault, ref: stripe-webhook-secret }
    server_ip: { from: infra, unit: hetzner, output: server_ip }
```

```
$ dogma deploy prod --new
dogma: checking dependencies...
dogma: normalizing config...
dogma: refreshing infra cache (hetzner)...
dogma: generating .sops.yaml from SSH host keys...
dogma: encrypting secrets for myproject-prod...
dogma: deploying backend (1.2.3.4)...
  → nixos-rebuild switch --target-host root@1.2.3.4 --flake .#myproject-prod
dogma: tagging deploy/v26.06.0001
dogma: done in 142s
```

```
$ dogma infra apply prod hetzner
dogma: normalizing config...
dogma: resolving credentials...
dogma: tofu init...
dogma: tofu apply...
  hcloud_server.backend: Creating...
  hcloud_server.backend: Creation complete (id=12345678)
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

```
$ dogma shell prod
dogma: entering prod shell (exit to return)
[dogma-prod 14:23:01] ~/myproject $
```

```
$ dogma env prod
export BACKEND_STRIPE_WEBHOOK_SECRET='whsec_...'
export BACKEND_SERVER_IP='1.2.3.4'
```

## Install

```bash
cargo install dogma-rust          # binary installed as `dogma`
# or from source
cargo build --release             # binary at target/release/dogma
```

Set `DOGMA_VAULT` per developer in `.bashrc` or per project in `shell.nix`:

```bash
export DOGMA_VAULT=pass           # or: envvar (default)
```

## Shell completion

**Bash** — add to `~/.bashrc`:
```bash
source <(dogma completions bash)
```

**Zsh** — add to `~/.zshrc`:
```bash
source <(dogma completions zsh)
```

**Fish** — install once:
```bash
dogma completions fish > ~/.config/fish/completions/dogma.fish
```

`<env>` is completed from `dogma.yml`. `<unit>` is completed from subdirectories of `infra.path`. `<host>` is completed from machine names in `dogma.yml`.

## Commands

### `dogma credentials <env>`

Prints `export VAR='value'` for all `infra.credentials`. Eval to load.

```bash
eval $(dogma credentials dev)
```

---

### `dogma env <env>`

Prints `export GROUP_FIELD='value'` for every secret, uppercased.

```bash
eval $(dogma env dev)
# → export BACKEND_API_KEY='...'
# → export BACKEND_SERVER_IP='...'
```

---

### `dogma output <env> [unit] [key]`

Reads from `.dogma/cache/<env>.json`.

```bash
dogma output dev                        # full JSON
dogma output dev hetzner                # one unit
dogma output dev hetzner server_ip      # raw value
```

---

### `dogma shell <env>`

Spawns a new shell with all secrets loaded as environment variables (same as `dogma env`). Prompt shows `[dogma-<env> HH:MM:SS]`. Exit to return.

```bash
dogma shell dev
```

---

### `dogma infra auth <env>`

Spawns a shell with `infra.credentials` loaded. Prompt shows `[dogma-<env> HH:MM:SS]`. Exit to return.

```bash
dogma infra auth dev
```

---

### `dogma infra apply <env> <unit>`

Runs: normalize → validate → `tofu init` → `tofu apply`. Credentials injected as env vars.

```bash
dogma infra apply dev hetzner
dogma infra apply dev hetzner --migrate-state
```

---

### `dogma infra destroy <env> <unit>`

Same as `apply` but runs `tofu destroy`.

---

### `dogma deploy <env> [host]`

Full deploy pipeline.

```bash
dogma deploy dev --new                         # new CalVer version, full pipeline
dogma deploy dev --latest                      # promote latest deploy/* tag
dogma deploy dev --version deploy/v26.06.0001  # promote specific tag
dogma deploy dev                               # interactive: pick from tag list
dogma deploy dev backend --new                 # one host only
```

**`--new` pipeline:**

| Step | Action |
|------|--------|
| 0 | Dep check: `ssh-keyscan`, `ssh-to-age`, `sops`, `nixos-rebuild` |
| 1 | Normalize + validate `dogma.yml` |
| 2 | Dirty tree check — commit or abort |
| 3 | Pre-deploy hooks |
| 4 | Infra cache refresh (all envs) |
| 5 | Generate `.sops.yaml` from SSH host keys |
| 6 | Encrypt secrets with sops, commit |
| 7 | `nixos-rebuild switch` per host |
| 8 | Git tags + push |
| 9 | Post-deploy hooks |

**Flags:**

| Flag | Description |
|------|-------------|
| `--new` | Create new CalVer version, run full pipeline |
| `--latest` | Promote latest `deploy/*` tag (no hooks) |
| `--version <tag>` | Promote specific tag (no hooks) |
| `--skip-infra` | Use existing infra cache |
| `--skip-sops` | Use existing `.sops.yaml` |
| `--refetch` | Clear all caches and re-fetch |
| `-m <msg>` | Commit message for dirty tree (only with `--new`) |

---

### `--time`

Global flag. Prints elapsed ms to stderr after any command.

```bash
dogma --time deploy dev --new
```

## dogma.yml reference

```yaml
name: myproject             # used in auto-derived vault paths

env:                        # list of environments
  - dev
  - prod

admin:                      # age/gpg/ssh keys for sops encryption
  - gpg: <fingerprint>
  - age: age1...
  - ssh: ~/.ssh/id_ed25519.pub

infra:
  cli: tofu                 # or: terraform (default: tofu)
  path: ./infra             # default: ./infra
  credentials:
    STATIC_VAR: value       # injected as-is into tofu
    SECRET_VAR:
      from: vault
      ref: <vault-key>

vault:
  <key>:
    pass: path/{env}/key    # {env} substituted per environment
    envvar: MY_VAR          # flat string or per-env map; auto-derived if omitted

machines:
  <name>:
    hostname: host-{env}    # {env} substituted; or per-env map
    user: deployer          # default: root
    ip: "1.2.3.4"           # static IP
    ip:                     # or from infra output
      from: infra
      unit: <unit>
      output: <output-key>
    secrets:                # secret groups to encrypt for this machine
      - <group>
    deployer: nixos-rebuild # default; only option currently

secrets:
  <group>:
    <field>:
      from: vault
      ref: <vault-key>
    <field>:
      from: infra
      unit: <unit>
      output: <output-key>

nix:
  path: ./nix               # default: ./nix
  secrets: ./nix/secrets    # default: ./nix/secrets
  sops: ./nix/.sops.yaml    # default: ./nix/.sops.yaml

deploy:
  strategy: nixos-rebuild   # default

hooks:
  pre-deploy:
    - ./custom/bump-version.sh
  post-deploy:
    - ./custom/notify-slack.sh
```

## Vault backends

Set `DOGMA_VAULT` per developer — not in `dogma.yml`.

| Backend | `DOGMA_VAULT` | How it resolves |
|---------|---------------|-----------------|
| `envvar` | (default) | Reads `$VAR` from process env. Var name from `vault.<key>.envvar.<env>`, auto-derived as `UPPER_SNAKE` if omitted |
| `pass` | `pass` | Calls `pass <path>`. Path from `vault.<key>.pass.<env>`, auto-derived as `<name>/<env>/<key>` if omitted |

## Hooks

Scripts must be executable. Both hooks receive:

| Variable | Example | Notes |
|----------|---------|-------|
| `DOGMA_VERSION` | `deploy/v26.06.0001` | CalVer tag |
| `DOGMA_ENV` | `dev` | Target environment |
| `DOGMA_HOSTS` | `backend\nworker` | Newline-separated machine names |
| `DOGMA_DEPLOYED_IPS` | `deployer@1.2.3.4` | Post-deploy only |

```bash
#!/usr/bin/env bash
# custom/bump-version.sh — write version into package.json
version="${DOGMA_VERSION#deploy/}"
jq --arg v "$version" '.version = $v' backend/package.json > tmp && mv tmp backend/package.json
```

## Generated files

Add to `.gitignore`:

```
.dogma/dogma-expanded.yml
.dogma/cache/
.dogma/age-keys/
```

| File | Purpose |
|------|---------|
| `.dogma/dogma-expanded.yml` | Normalized config with all defaults filled in |
| `.dogma/cache/<env>.json` | Cached infra outputs |
| `.dogma/age-keys/<host>.pub` | Cached SSH→age host keys |

## Runtime dependencies

The binary runs on any Linux with no runtime deps. External tools are checked lazily — only when the command that needs them actually runs.

| Tool | Required by |
|------|-------------|
| `pass` | `DOGMA_VAULT=pass` |
| `tofu` / `terraform` | `infra apply`, `infra destroy`, `deploy` |
| `ssh-keyscan` | `deploy --new` |
| `ssh-to-age` | `deploy --new` |
| `sops` | `deploy --new` |
| `nixos-rebuild` | `deploy` (nixos-rebuild strategy) |
