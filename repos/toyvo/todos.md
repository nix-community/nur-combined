# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

## Manually written down by human

- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook
- [ ] build-test `packages.x86_64-linux.ghostex` on a Linux machine (only
      `aarch64-darwin` has been built; Linux evaluation passes) and launch the
      GUI to confirm the CEF runtime download and X11/XWayland path work
- [ ] run `darwin-rebuild switch --flake .#FQ-M-6KL6HVKQ` to apply the
      opencode.json Ghostex fix below (home-manager will replace the file with
      managed content including the Ghostex plugin entry, then the new
      activation script converts it to a writable copy)

## Forgejo (git.toyvo.dev) Enhancements

## Forgejo Actions Enhancements (CI runner on the nas) (git.toyvo.dev)

- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
