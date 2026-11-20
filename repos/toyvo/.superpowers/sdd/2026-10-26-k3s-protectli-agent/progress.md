# SDD ledger — plan: docs/superpowers/plans/2026-10-26-k3s-protectli-agent.md
Ruling: work in place on jj working copy (no git worktree) — same as previous plans; baseline `jj status` clean.
Pre-flight: Task 1 produces Protectli agent config via existing `nixcfg.k3s.*`; no module changes, no shared interfaces to conflict. Upstream assertions (agent needs serverAddr, disableAgent server-only) already verified in nixpkgs source.
Task 1 BLOCKED on addressing facts (ruling + stop-and-ask, not a stall):
- Finding: Protectli cherry-picks modules and does NOT import the k3s module (fix: add `inputs.nixcfg.modules.nixos.k3s` to its imports; will do with the rest).
- Finding: its flake config addresses br0/VLANs as 192.168.x (old standalone-firewall layout), yet 10.1.0.6 pings — running system ≠ this config, or .6 lives on enp1s0 via DHCP. firewallInterfaces value and node-IP behavior depend on which interface actually holds 10.1.0.6, which I cannot observe from nas. Guessing risks opening ports on the wrong interface or a disruptive network rewrite on switch.
- Need from user (protectli shell): `ip -brief addr` + `readlink /run/current-system`.
Task 1: complete (RED n/a — new config; GREEN: k3s eval pins role agent/serverAddr/no-init/no-disableAgent, global fw clean, enp1s0 scoped; k3s module import added to cherry-picked imports)
Task 2: complete (toplevel nc0940lzxh..., unit is `k3s agent --server https://10.1.0.3:6443`, no disable-agent/cluster-init)
Final review: self-review (no subagent tool). Scope is the 2-file diff (Protectli config + todos); spec/plan docs under docs/superpowers/ are gitignored by repo policy — local-only by design, consistent with prior plans.
Findings: none blocking. Node-IP-on-enp1s0 assumption carries the documented nodeIP-passthrough fallback. Disk pre-flight is a user step. No fix pass.
Task 3 (user deploy) + Task 4 checkbox pending user confirmation.
Ruling: red main for nas (`userPresets.agent` missing after 0ef0628e refactor; agent.nix never migrated, only nas consumes the new key) is the user's in-flight refactor — NOT fixed here. Only nas affected (sole consumer). My k3s change provably unrelated (no userPresets interaction; server-role code path identical, confirmed on macmini/router evals). Ruling: report precisely, offer the mirror-root.nix shape, let user apply.
Task 3: complete (user deploy; protectli Ready, worker roles, joined via enp1s0; nodeIP fallback not needed)
Task 4: complete (todos checked off)
Sidebar (user-authorized nas fix): un-reddened nas after 0ef0628e refactor fallout. (1) Added `options.userPresets.agent.enable` aliasing `nixcfg.users.agent.enable` via mkDefault (only nas consumes either spelling). (2) Fixed moved home-profile block referencing NixOS `config.services.hermes-agent` — now `osConfig` with static fallback (matches session.nix precedent). Verified: nas eval+build green, agent user + dynamic git name intact. Only nas affected.
