# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

- [x] Consolidate `hermes` user into `agent`: set `shell = lib.mkDefault pkgs.bash` in `modules/os/users/agent.nix`, and override `services.hermes-agent.user/group = "agent"` with `createUser = false` in `nas/configuration.nix`. After rebuild the `hermes` passwd entry will disappear automatically.
- [ ] Genericize remaining `hermes`→`agent` descriptions in `secretspec.toml` (`HERMES_MAX_ITERATIONS`, `OPENCODE_API_KEY`) and `nas/configuration.nix` comments. Keep upstream API names (`services.hermes-agent`, `inputs.hermes-agent`, `HERMES_*` env, `hermes-cli` toolset) as-is.
- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook
- [ ] Jellyfin LDAP: `ldap.diekvoss.net` resolves to router (10.1.0.1) with nothing on 6636; Jellyfin `LDAP-Auth.xml` manually pointed at `10.200.0.16:6636`. Decide durable fix: Technitium split-horizon override for `ldap.diekvoss.net` -> `10.200.0.16`, router TCP proxy for 6636, or document direct-IP convention

## Forgejo (git.toyvo.dev) Enhancements

## Forgejo Actions Enhancements (CI runner on the nas) (git.toyvo.dev)

- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
- [ ] Consider sharding the ~3h `checks.<system>.all` monolith build (matrix over package groups, higher `-j`, or nix-fast-build) so scheduled CI is less exposed to any single interruption
- [ ] pi MCP parity: opencode also configures `slack` and `chrome-devtools` MCP servers; add them to `programs.pi-coding-agent.mcpServers` (shared `nixos`, per-profile `github-*`, and work `atlassian` are done)
- [x] Durable repo maintainer MVP (design: `docs/superpowers/specs/2026-10-20-durable-maintainer-design.md`, plan: `docs/superpowers/plans/2026-10-20-durable-maintainer-mvp.md`): `services.repo-maintainer` module + `repo-maintainer` package polling `toyvo/nixcfg` tasks, dispatching on infra-cancel, opening separate `fix/ci-*` PRs for eval breaks, approval-gated merge. Dry-run validated read-only against live Forgejo.
  - Manual before nas deploy: create Forgejo PAT (repo scope), add value as `repo-maintainer-forgejo-token` via `sops secrets.yaml` (activation fails without it); verify `forgejoLogDir` (`/mnt/POOL/forgejo/data/actions_log` default guess) holds `toyvo/nixcfg/<xx>/<id>.log[.zst]`.
  - Follow-up: wire `Harness.open` SQLite (`@earendil-works/pi-durable`) replacing `attempts.json`; model-driven fix writer (`planFixBranch`/`buildFixPrBody`/`prepareFixWorkdir` ready); pre-existing nas `forgejo-runner` option migration (`tokenFile`/`name`/`settings` removed upstream) is unrelated and still red in `nix flake check`.
- [x] Stop hosting odysseus/open-webui on nas (2026-10-24): `services.odysseus` disabled + firewall port 7000 closed; `nas.services.odysseus` and stale `open-webui` host removed from `homelab.nix` (drops `odysseus.diekvoss.net` / `chat.diekvoss.net` vhosts). Unblocks `nixos-rebuild switch` which failed building `python3.14-urllib3-future-2.25.902` (34 SOCKS/network test failures, not in binary cache).
- [x] Upstream `python3.14-urllib3-future-2.25.902` test failures blocking CI (`checks.all` builds odysseus): fixed by extending the scoped `packageOverrides` in `pkgs/odysseus/derivation.nix` to `doCheck=false` for `urllib3-future`, `niquests` (same SOCKS sandbox failures on Linux), and `caldav` (local-network fixtures). Full `nix build .#packages.x86_64-linux.odysseus` verified green.
- [x] Fix CI update failures caused by Forgejo GITHUB_TOKEN being incorrectly used for api.github.com requests (fixed in scripts/update-lib.ts)
- [ ] hermes-dashboard OIDC via Authentik (502 fixed once live): migrated from custom `services.hermes-dashboard` module (dead `--insecure` flag) to upstream `services.hermes-agent.backend.mode = "dashboard"` with `dashboard.oauth.self_hosted` + `public_url`/`trusted_proxies` in nas config and `forwardAuthGate = false` in homelab.nix. Manual steps: (1) create Authentik OAuth2/OIDC provider + app (slug `hermes`, confidential, redirect `https://hermes.diekvoss.net/auth/callback`); (2) put client ID in nas `settings.dashboard.oauth.self_hosted.client_id` (placeholder now); (3) append `HERMES_DASHBOARD_OIDC_CLIENT_SECRET=<secret>` to `agent.env` via `sops secrets.yaml`; (4) `sudo chown -R agent:agent /mnt/POOL/agent/.hermes` (fixes gateway + dashboard `state.db` PermissionError from root-owned files); (5) rebuild nas + router (Caddy vhost change).

## Neovim

- [ ] Drop vendored `mega.logging`/`mega.cmdparse` from `pkgs/toyvo-neovim/default.nix` once nvf packages avante.nvim's `ColinKennedy/mega.*` dependencies upstream
