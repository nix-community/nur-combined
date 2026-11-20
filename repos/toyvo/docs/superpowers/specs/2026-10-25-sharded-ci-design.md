# Design: sharded CI to fix nas runner OOMs

- Date: 2026-10-25
- Approach picked: option 1 — sharded aggregates in the flake + matrix in CI (from brainstorming 2026-10-25). Replaces the monolithic `checks.all` / full `nix flake check` with per-slice `nix build` invocations so no single nix process ever evaluates the whole flake at once.

## Intent and why

The nas Forgejo runner (31 GB RAM + 15 GB zram) is OOM-killed during CI. A single `nix flake check -j 1` sits at ~19 GB RSS because it evaluates all 18 `nixosConfigurations`, 213 `packages.x86_64-linux` (mostly versioned MC servers), `darwin`/`home` configs, `deployChecks`, and the `checks.all` aggregate (which references every other check) in one process. `-j 1` only limits build parallelism, not evaluation memory. The workflow then repeats full evaluations ~5x (`flake show` + `flake check` + `checks.all` + 3 NUR legs). Result: kernel OOM-kills the whole runner unit mid-job (seen 2026-10-25, 18 GB mem + 12 GB swap peak).

## Goals

- Same effect as today: every host toplevel and every package still gets built and pushed to the binary cache on green runs.
- No single nix invocation evaluates the whole flake; per-shard peak target ~2–4 GB.
- Total wall time stays in the same ballpark (~3 h sequential on nas); reliability matters more than speed.

## Non-goals / anti-goals

- No new builders, no new hardware, no extra swap (zram stays as-is).
- No change to what `nix flake check --no-build` evaluates locally; only CI invocation pattern changes (plus removing the `all` footgun).
- Not fixing NUR-leg memory separately unless it OOMs after this change.
- Failure mode to avoid: "green but skipped half the closure" — sharding must provably cover everything `checks.all` + all toplevels covered.

## Constraints

- Jobs run on the `native` nas runner, host executor, shared system store.
- nas runs many services (immich, nextcloud, postgres, containers); only ~7 GB free before CI starts — CI must stay lean.
- `nix flake check` inherently forces all outputs; CI must stop calling it (and `flake show`) entirely.
- nix attribute access is lazy: `nix build .#nixosConfigurations.<host>...` only forces that host, and `nix build .#checks.<system>.<shard>` only forces that slice — this is what makes sharding work.

## Approaches considered

1. **Sharded aggregates + matrix (picked).** Define `checks.all-shard-N` in `flake.nix`, build toplevels per-host and shards per-slice in separate `nix build -j 1` steps. Each process holds one slice; memory frees between steps. Same coverage, no new tools. Cost: small flake + workflow edits.
2. Dynamic partition via `flake show --json` + `jq`. Rejected: `flake show` itself evaluates everything (~19 GB) and OOMs before sharding starts.
3. Remote builders / `nix-fast-build`. Rejected: doesn't fix the single-process evaluation blowup, which is the actual killer.

## The plan (what the implementer builds)

### flake.nix (`perSystem.checks`)

- Partition the existing package/devShell/deploy check set into 4 shards (round-robin over sorted check names so MC-server version bombs spread evenly; deploy + devShell checks pinned to shard 1).
- Expose `checks.all-shard-1..4`, each a `runCommand` aggregating its slice (same pattern as today's `all`).
- Delete `checks.all` so nothing (human or CI) can accidentally invoke the monolith again. Update the `todos.md` sharding item when done.
- Keep per-check outputs unchanged so `nix build .#checks.<system>.<name>` still works for debugging.

### .forgejo/workflows/build.yml (`build` job)

- Delete: `nix flake show`, `nix flake check -j 1`, `nix build .#checks.<system>.all`.
- Add `toplevels` matrix (one entry per `nixosConfigurations` host buildable on x86_64-linux; aarch64 hosts included — nas has binfmt — but grouped 2–3 per step to bound time): each step runs `nix build -j 1 -L .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`.
- Add `packages` matrix (4 steps): each runs `nix build -j 1 -L .#checks.<system>.all-shard-N`.
- Keep `update`, `merge`, `nur` jobs unchanged in this pass. NUR legs already run as separate processes; revisit only if they OOM.
- Keep `timeout-minutes: 240` on the build job; keep `-j 1 -L` flags.

### Runner guardrail (nas config, small)

- Set `systemd.services.forgejo-runner-nas.serviceConfig.MemoryHigh/MemoryMax` (e.g. 26 G / 28 G) so a future blowup fails the job instead of starving postgres/forgejo and forcing a kernel OOM-kill of the whole unit. Keep `restartIfChanged = false`.

## What's left to the builder

- Exact shard count (4 is a starting point; 3–6 all fine) and host grouping, as long as every current `checks.all` input and every `nixosConfigurations` toplevel is covered by exactly one shard/step. Provide a CI-side coverage assertion (e.g. compare shard inputs against the old `all` input list in a comment or assert).
- Whether toplevel matrix lists hosts statically or derives them with `nix eval --apply builtins.attrNames` (cheap, doesn't force values).
- Sequencing within the job (toplevels first so eval breaks surface fast, packages after) and log grouping.

## Open questions for owner (answer before plan)

1. Drop `checks.all` entirely, or keep it for local use with a warning comment? (Proposal: drop it.)
2. Should aarch64 toplevels (PineBook, rpis, oracle, utm, pixel10a, MacBook-Pro-NixOS) build on nas via binfmt in CI, or skip emulation and only build x86_64-linux hosts + x86_64 packages? (Proposal: build everything, same as today.)
