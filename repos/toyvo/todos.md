# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

- [ ] Finish hermes → agent generic identity rename (syncthing removal intentional — wiki moved to forgejo, agents use git): remaining `hermes` refs are mostly upstream API (`services.hermes-agent`, `inputs.hermes-agent`, `HERMES_*` env, `hermes-cli` toolset — keep). Still to fix: full `nas` eval breaks on `home-manager.users.agent.home.homeDirectory` conflict (`/mnt/POOL/agent` vs `/var/empty` from system user default) because upstream `hermes-agent` module still creates `users.users.hermes` (home now `/mnt/POOL/agent`) while new `users.users.agent` has home `/var/empty` — set `services.hermes-agent.user/group = "agent"` + `users.users.agent.home`, verify no duplicate users/overlapping subUidRanges; genericize `secretspec.toml` descriptions (`HERMES_MAX_ITERATIONS`, `OPENCODE_API_KEY`) and `nas/configuration.nix` comments
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
- [ ] Drop local open-webui `makeWrapperArgs` workaround in `configurations/nixos/nas/configuration.nix` once upstream nixpkgs splits the combined `--set FRONTEND_BUILD_DIR ...` string (breaks refactored `wrapPythonProgramsIn` hook: `makeWrapper doesn't understand the arg`)
- [x] Fix CI update failures caused by Forgejo GITHUB_TOKEN being incorrectly used for api.github.com requests (fixed in scripts/update-lib.ts)

## Neovim

- [ ] Drop vendored `mega.logging`/`mega.cmdparse` from `pkgs/toyvo-neovim/default.nix` once nvf packages avante.nvim's `ColinKennedy/mega.*` dependencies upstream
