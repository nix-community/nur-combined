# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

## Manually written down by human

- [ ] allow some ip ranges past forward auth, eg 10.200.x.x
- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook

## Forgejo (git.diekvoss.net)

### Forgejo Actions (CI runner on the nas)

- [x] Create a runner registration token: Forgejo Site Administration → Actions → Runners → Create new runner
- [x] Add `forgejo-runner-token` to `secrets.yaml` with content `TOKEN=<registration token>` (`sops secrets.yaml`)
- [ ] Deploy the nas (`deploy .#nas`), then verify the runner shows as online under Site Administration → Actions → Runners
- [ ] Add `CACHIX_AUTH_TOKEN` under the repo's Settings → Actions → Secrets on Forgejo
- [ ] Port the GitHub-only automation still in `.github/workflows/build.yml` (update-flake-lock PRs, auto-format PRs, `gh api` check reporting) — these use the GitHub API and need Forgejo equivalents (Forgejo API + curl, or a tea-based flow)

### Enhancements

- [ ] Git over SSH via the domain: forward port 22 on the router and switch the router's ssh port (e.g. `2222` & `22` → `nas:22`) so clone URLs like `ssh://forgejo@git.diekvoss.net/user/repo.git` work
- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
