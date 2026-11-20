# SDD ledger — plan: docs/superpowers/plans/2026-10-25-k3s-nas-macmini.md
Ruling: work in place on jj working copy (no git worktree) — repo uses jj with `jj bookmark set main` workflow; a git worktree would break sops/jj state. Baseline clean (`jj status` no changes). Cost if wrong: changes land directly in working copy; mitigated by jj's automatic undo.
Pre-flight: Task 1 produces `nixcfg.k3s.*`; Tasks 2-3 consume exact option names. No conflict: plan pins names (enable/role/clusterInit/serverAddr/tokenFile/extraSANs/disable). Upstream `services.k3s` options verified in nixpkgs source (role/serverAddr/tokenFile/clusterInit/disable/extraFlags all exist). Spec authority: design doc.
Ruling: jj repo — per-task `git commit` replaced by single working-copy change + `jj describe` at end. Cost if wrong: less granular history; acceptable for one small feature.
Task 1: complete (eval `nix flake show` → PASS, no eval error)
Task 2: complete (token via sops set ok, 2b rg checks PASS, nas toplevel builds, k3s.service shows server --cluster-init --disable=traefik --tls-san x6, no --server)
Task 3: complete (macmini toplevel builds, k3s.service shows server --server https://10.1.0.3:6443, no --cluster-init, token-file + tls-san ok)
Task 4: complete (todos.md updated, `nix fmt` PASS, both systems' nixcfg.k3s eval to pinned values)
Final review: self-review (no subagent tool).
Final: fixed missing-tokenFile assertion — RED (eval with tokenFile=null → assertion fires), GREEN (both systems eval true).
Final: minor (deferred): firewall also opens 51820-51821/udp though default flannel backend only needs 8472; harmless, revisit if switching to wireguard-native.
Final: minor (deferred): homelab.nix has no k3s service entries (no ingress yet); add when Caddy integration lands.
Deploy verified 2026-10-26: both nodes Ready (control-plane,etcd). Root cause of join failure was etcd 2379-2380/tcp firewalled; fix deployed nas-then-mac, no stale member, no reset needed.
