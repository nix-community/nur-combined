# TODOs

## nas libvirtd (pre-existing, unrelated to k3s)

- [ ] `libvirtd.service` fails since ~Oct 24 with `status=243/CREDENTIALS`. Root cause 2026-10-26: `/var/lib/systemd/credential.secret` (TPM-less host key) is 0 bytes, truncated Oct 12 — so `systemd-creds encrypt` fails (`Failed to determine local credential host secret`) and `LoadCredentialEncrypted` can never decrypt. Only libvirt uses encrypted credentials; no stored secrets. Fix: `sudo systemd-creds setup && sudo systemctl start virt-secret-init-encryption.service && sudo systemctl restart libvirtd.service` (old March key blob already deleted, unrecoverable but unneeded). 2026-10-26: `setup` fails because the 0-byte `/var/lib/systemd/credential.secret` exists but is `too small, refusing` (debug output). Fix: delete the empty file so `setup` regenerates it, then re-mint libvirt key + restart libvirtd. Still need VM-use answer; if unused, disable libvirtd instead. If no VMs are used, set `virtualisation.libvirtd.enable = false` instead.

## k3s cluster (nas + MacMini-Intel, day one)

- [x] k3s two-server cluster declared (design: `docs/superpowers/specs/2026-10-25-k3s-nas-design.md`, plan: `docs/superpowers/plans/2026-10-25-k3s-nas-macmini.md`): `nixcfg.k3s` wrapper module, nas cluster-init server, MacMini-Intel joins via `https://10.1.0.3:6443`, shared sops `k3s-token`, traefik disabled.
  - Manual rollout order (eval verified, not yet deployed): deploy nas first, wait for `k3s kubectl get nodes` Ready, then deploy MacMini-Intel.
- [x] Deploy + verify (2026-10-26): `nixos-rebuild switch --flake .#nas`, then `.#MacMini-Intel-NixOS`; `kubectl get nodes` shows nas + macmini-intel-nixos Ready (control-plane,etcd). Required opening etcd 2379-2380/tcp in `nixcfg.k3s` firewall on both nodes.
- [x] Router joined as etcd-only third server (2026-10-26).
- [x] Protectli joined as worker agent (2026-10-26): Ready, `<none>` roles as designed; etcd stays 3 voters.
- [ ] Traefik NodePorts 30080/30443 live (code done on nas+macmini); deploy both, verify svc + cross-node pod curl.
- [x] homepage serves from cluster (2026-10-26): manifests live, Caddy `upstreams` flip for `diekvoss.net` verified 200 with auth gate, nas-native service retired (file deleted, 8082 closed). Failover verified 2026-10-26 in both directions (k3s stopped on nas → 200 via macmini, and vice versa).
- [ ] homepage widget secrets via secretspec (contract `k8s/homepage/secretspec.toml` + Deployment `envFrom` done; design `docs/superpowers/specs/2026-10-26-homepage-secretspec-design.md`, plan `docs/superpowers/plans/2026-10-26-homepage-secretspec.md`): user to check `secretspec --version` + `pass-cli` pin, copy the 17 keys to `homepage/default/*` in the `secretspec` Pass vault, run the populate loop, verify widgets + `secretspec check`.
- [x] Storage platform proven (2026-10-26): NFS static PVs (`nfs-pool`, csi-driver-nfs v4.13.6) + local-path DB pattern with dump-to-NFS verified end to end, proof cleaned up. Note: `pool-k3s-test` PV sits `Released` (Retain) — clear claimRef before reuse.
- [ ] First real stateful migration off the pattern (candidate: pick DB-backed service; template is StatefulSet + nodeAffinity nas + CronJob dump to NFS).
- [ ] Caddy ingress integration for cluster services.
- [ ] aarch64 nodes (rpis) after x86_64 stable.

Outstanding work and follow-up items for this repository.

- [ ] Explore k3s cluster (server on nas, agents on router/Protectli/oracle/MacMini-Intel/MacMini-M1) for web services; decide topology, storage, and ingress vs existing Caddy + nixos-containers

> AI agents: per the "Todo Tracking" section of [AGENTS.md](AGENTS.md), you are
> expected to keep this file up to date — check off completed items, and add
> deferred work or manual steps before finishing a task.

- [x] Consolidate `hermes` user into `agent`: set `shell = lib.mkDefault pkgs.bash` in `modules/os/users/agent.nix`, and override `services.hermes-agent.user/group = "agent"` with `createUser = false` in `nas/configuration.nix`. After rebuild the `hermes` passwd entry will disappear automatically.
- [ ] Genericize remaining `hermes`→`agent` descriptions in `secretspec.toml` (`HERMES_MAX_ITERATIONS`, `OPENCODE_API_KEY`) and `nas/configuration.nix` comments. Keep upstream API names (`services.hermes-agent`, `inputs.hermes-agent`, `HERMES_*` env, `hermes-cli` toolset) as-is.
- [ ] Revert `nixos-avf` flake input to `github:nix-community/nixos-avf` once [PR #45](https://github.com/nix-community/nixos-avf/pull/45) (remove `boot.initrd.systemd.enable`) is merged. Currently pinned to `github:mio-19/nixos-avf/4c557dc7444eb6b6b16937e9e788cbd20496748a`.
- [ ] Revert `preservation` flake input to `github:WilliButz/preservation` once [PR #36](https://github.com/WilliButz/preservation/pull/36) (remove `boot.initrd.systemd.enable` references) is merged. Currently pinned to `github:mjm/preservation/ed8dbeaac0ad240341259c814cade7163a53fc1f`.
- [ ] setup forwarding to binary cache/nas with nix.settings.post-build-hook
- [ ] Jellyfin LDAP: `ldap.diekvoss.net` resolves to router (10.1.0.1) with nothing on 6636; Jellyfin `LDAP-Auth.xml` manually pointed at `10.200.0.16:6636`. Decide durable fix: Technitium split-horizon override for `ldap.diekvoss.net` -> `10.200.0.16`, router TCP proxy for 6636, or document direct-IP convention

## Forgejo (git.toyvo.dev) Enhancements

## Forgejo Actions Enhancements (CI runner on the nas) (git.toyvo.dev)

- [ ] Authentik OIDC login for Forgejo
- [ ] Periodic backups via `services.forgejo.dump.enable`
- [ ] Homepage widget (`type: gitea`) with an API key stored in sops as `HOMEPAGE_VAR_FORGEJO_API_KEY`
- [x] Consider sharding the ~3h `checks.<system>.all` monolith build (matrix over package groups, higher `-j`, or nix-fast-build) so scheduled CI is less exposed to any single interruption — done 2026-10-25 (design: `docs/superpowers/specs/2026-10-25-sharded-ci-design.md`, plan: `docs/superpowers/plans/2026-10-25-sharded-ci.md`): `checks.all` replaced by `all-shard-1..4`, CI `build` job now runs per-host toplevels + per-shard builds (no more `flake show`/`flake check` monolith), runner capped at MemoryHigh 26G/Max 28G.
- [ ] pi MCP parity: opencode also configures `slack` and `chrome-devtools` MCP servers; add them to `programs.pi-coding-agent.mcpServers` (shared `nixos`, per-profile `github-*`, and work `atlassian` are done)
- [x] Durable repo maintainer MVP (design: `docs/superpowers/specs/2026-10-20-durable-maintainer-design.md`, plan: `docs/superpowers/plans/2026-10-20-durable-maintainer-mvp.md`): `services.repo-maintainer` module + `repo-maintainer` package polling `toyvo/nixcfg` tasks, dispatching on infra-cancel, opening separate `fix/ci-*` PRs for eval breaks, approval-gated merge. Dry-run validated read-only against live Forgejo.
  - Manual before nas deploy: create Forgejo PAT (repo scope), add value as `repo-maintainer-forgejo-token` via `sops secrets.yaml` (activation fails without it); verify `forgejoLogDir` (`/mnt/POOL/forgejo/data/actions_log` default guess) holds `toyvo/nixcfg/<xx>/<id>.log[.zst]`.
  - Follow-up: wire `Harness.open` SQLite (`@earendil-works/pi-durable`) replacing `attempts.json`; model-driven fix writer (`planFixBranch`/`buildFixPrBody`/`prepareFixWorkdir` ready); pre-existing nas `forgejo-runner` option migration (`tokenFile`/`name`/`settings` removed upstream) is unrelated and still red in `nix flake check`.
- [x] Stop hosting odysseus/open-webui on nas (2026-10-24): `services.odysseus` disabled + firewall port 7000 closed; `nas.services.odysseus` and stale `open-webui` host removed from `homelab.nix` (drops `odysseus.diekvoss.net` / `chat.diekvoss.net` vhosts). Unblocks `nixos-rebuild switch` which failed building `python3.14-urllib3-future-2.25.902` (34 SOCKS/network test failures, not in binary cache).
- [x] Upstream `python3.14-urllib3-future-2.25.902` test failures blocking CI (`checks.all` builds odysseus): fixed by extending the scoped `packageOverrides` in `pkgs/odysseus/derivation.nix` to `doCheck=false` for `urllib3-future`, `niquests` (same SOCKS sandbox failures on Linux), and `caldav` (local-network fixtures). Full `nix build .#packages.x86_64-linux.odysseus` verified green.
- [x] Fix CI update failures caused by Forgejo GITHUB_TOKEN being incorrectly used for api.github.com requests (fixed in scripts/update-lib.ts)
- [ ] hermes-dashboard OIDC via Authentik (502 fixed once live): migrated from custom `services.hermes-dashboard` module (dead `--insecure` flag) to upstream `services.hermes-agent.backend.mode = "dashboard"` with `dashboard.oauth.self_hosted` + `public_url`/`trusted_proxies` in nas config and `forwardAuthGate = false` in homelab.nix. Manual steps: (1) create Authentik OAuth2/OIDC provider + app (slug `hermes`, confidential, redirect `https://hermes.diekvoss.net/auth/callback`); (2) put client ID in nas `settings.dashboard.oauth.self_hosted.client_id` (placeholder now); (3) append `HERMES_DASHBOARD_OIDC_CLIENT_SECRET=<secret>` to `agent.env` via `sops secrets.yaml`; (4) `sudo chown -R agent:agent /mnt/POOL/agent/.hermes` (fixes gateway + dashboard `state.db` PermissionError from root-owned files); (5) rebuild nas + router (Caddy vhost change).

## Module registry refactor (2026-10-25)

- [x] Removed `default` aggregators from `modules/{os,nixos,darwin,home}/default.nix` (now pure registries + new `modules.os`/`osModules` output); every module declares its own `imports`, every host imports a minimal set (plan: `docs/superpowers/plans/2026-10-25-remove-default-modules.md`). Verified: `nix flake show` PASS, `nix flake check --no-build` all green, dry-run builds for wsl + MacBook-Pro darwin + deck@steamdeck green.
- [ ] `nix flake check` (full, with builds) still red on `checks.aarch64-darwin.tinycast` (dmg unpack fails; pre-existing package issue in `pkgs/tinycast`, unrelated to the refactor).

## Neovim

- [ ] Drop vendored `mega.logging`/`mega.cmdparse` from `pkgs/toyvo-neovim/default.nix` once nvf packages avante.nvim's `ColinKennedy/mega.*` dependencies upstream
