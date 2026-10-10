# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook
- [ ] Jellyfin LDAP: `ldap.diekvoss.net` resolves to router (10.1.0.1) with nothing on 6636; Jellyfin `LDAP-Auth.xml` manually pointed at `10.200.0.16:6636`. Decide durable fix: Technitium split-horizon override for `ldap.diekvoss.net` -> `10.200.0.16`, router TCP proxy for 6636, or document direct-IP convention

## Forgejo (git.toyvo.dev) Enhancements

## Forgejo Actions Enhancements (CI runner on the nas) (git.toyvo.dev)

- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
- [ ] Consider sharding the ~3h `checks.<system>.all` monolith build (matrix over package groups, higher `-j`, or nix-fast-build) so scheduled CI is less exposed to any single interruption
- [ ] pi MCP parity: opencode also configures `slack` and `chrome-devtools` MCP servers; add them to `programs.pi-coding-agent.mcpServers` (shared `nixos`, per-profile `github-*`, and work `atlassian` are done)

## Neovim

- [ ] Drop vendored `mega.logging`/`mega.cmdparse` from `pkgs/toyvo-neovim/default.nix` once nvf packages avante.nvim's `ColinKennedy/mega.*` dependencies upstream
