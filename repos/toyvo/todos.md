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
- [x] Add `forgejo-runner-token` to `secrets.yaml` (`sops secrets.yaml`) — content is the **bare registration token**; the `TOKEN=` env-file wrapper is generated via `sops.templates`
- [ ] Deploy the nas (`deploy .#nas`), then verify the runner shows as online under Site Administration → Actions → Runners
- [ ] Add `CACHIX_AUTH_TOKEN` under the repo's Settings → Actions → Secrets on Forgejo
- [x] Port the GitHub-only automation (flake.lock updates, auto-format, merge-on-green) to Forgejo Actions; GitHub CI removed entirely (`.github/` deleted)

### Enhancements

- [x] Git over SSH via the domain: router admin sshd moved to port 2222, and TCP/22 on the router relays to `nas:22` (`git-ssh-relay` socat service) — standard clone URLs work: `forgejo@git.diekvoss.net:user/repo.git`. SSH client config for the router (port 2222) is in `modules/home/programs/ssh.nix`. Needs a router + nas deploy and home-manager switch to take effect.
- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
