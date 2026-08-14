# TODOs

Outstanding work and follow-up items for this repository.

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

## Forgejo (git.diekvoss.net)

### Manual steps to finish the deployment

- [ ] Deploy the nas and router (`deploy .#nas`; router via `nixos-rebuild switch --flake .#router`)
- [ ] Add a `git.diekvoss.net` A record in Cloudflare pointing at the router (the `*.diekvoss.net` wildcard cert already covers it)
- [ ] Create the initial admin user (self-registration is disabled). On the nas:
  ```bash
  sudo -u forgejo $(systemctl show forgejo -p ExecStart --value | awk '{print $1}') \
    --work-path /mnt/POOL/forgejo --config /mnt/POOL/forgejo/custom/conf/app.ini \
    admin user create --admin --username toyvo --email collin@diekvoss.com --password 'CHANGEME'
  ```

### Enhancements

- [ ] Git over SSH via the domain: forward port 22 on the router and switch the router's ssh port (e.g. `2222` & `22` → `nas:22`) so clone URLs like `ssh://forgejo@git.diekvoss.net/user/repo.git` work
- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`

## Manually written down by human

- [ ] allow some ip ranges past forward auth, eg 10.200.x.x
- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook
