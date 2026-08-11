# Plan: split modules into nixos/common/home-manager + HM mcp-gateway

## Goal
- Add a home-manager module for mcp-gateway so it works for home-manager users too.
- Split `modules/` into `nixos/`, `common/`, `home-manager/` once.
- Backwards compatibility: nix attributes must not change (`services.mcp-gateway`,
  `nixosModules` attr names, `modules/default.nix` importability).
- Introduce shared `common/mcp-gateway.nix` so options/config-generation are not
  duplicated between the NixOS and home-manager modules.

## Final structure
```
modules/
  default.nix                  # shim: import ./nixos          <- nixosModules attr names unchanged
  common/
    mcp-gateway.nix            # shared options + config generation (single source)
  nixos/
    default.nix                # index: all existing NixOS modules (git mv, same names)
    mcp-gateway.nix            # systemd system service
    authentik.nix  endfield.nix  homepage.nix  hoyolab.nix  kes.nix  ocis.nix
    prometheus-exporters/  rinetd.nix  rustic.nix  syncyomi.nix  telemt.nix  whoogle.nix  wopiserver.nix
  home-manager/
    default.nix                # index: { mcp-gateway = ../mcp-gateway/home-manager.nix }
    mcp-gateway.nix            # systemd *user* service
```

Both platform modules import the shared module via `../common/mcp-gateway.nix`.

## Content split

### common/mcp-gateway.nix (shared)
- Options: `enable, package, settings, capabilities, configFile, logLevel,
  logFormat, environmentFile, extraPackages, extraArguments, extraEnvironment,
  memoryMax` + `stateDir` as `nullOr path, default = null` (platform resolves default)
- Config generation: `capabilitiesDir`, `settings'`,
  `configFile = format.generate "gateway.yaml" settings'`
- No service definition at all.

### nixos/mcp-gateway.nix
- Platform options: `user`, `group`, `openFirewall`; `stateDir` default `/var/lib/mcp-gateway`
- `systemd.services.mcp-gateway`: path (`[ nodejs bash ] ++ extraPackages`),
  environment (`HOME=stateDir`, logLevel/logFormat/extraEnvironment), full
  hardening block, `EnvironmentFile`, `StateDirectory`, `MemoryMax`
- `users.groups`/`users.users`, firewall rule

### home-manager/mcp-gateway.nix
- Same `services.mcp-gateway` namespace, imports `../common/mcp-gateway.nix`
- `systemd.user.services.mcp-gateway`: Service with ExecStart
  (`cfg.package` + `configFile` + extraArguments), `path = [ nodejs bash ] ++
  extraPackages`, Environment (logLevel/logFormat/extraEnvironment,
  `EnvironmentFile`), `MemoryMax`, `WorkingDirectory`
- `stateDir` default → `${config.xdg.stateHome}/mcp-gateway`, created via
  `systemd.user.tmpfiles.rules`
- No `user`/`group`/`openFirewall` (user context)
- No home-manager flake input/test (user verifies manually); `homeManagerModules`
  attr is exposed only.

## Wiring & docs
- `flake.nix`: add `homeManagerModules = import ./modules/home-manager;`
- `README.md`: update module doc links to new paths

## Verification
- `nix eval` — `nixosModules` attr names identical to today
- Rebuild/eval existing NixOS test config → system drv OK
- `nix-instantiate --eval` HM module path for syntax sanity

## Commits (conventional)
1. `refactor(modules): split nixos modules into modules/nixos` — pure `git mv` + shim
2. `refactor(modules/mcp-gateway): extract shared common module` — move options/config-gen to common/mcp-gateway.nix, NixOS module imports it (no behavior change)
3. `feat(modules): add home-manager mcp-gateway module` — HM module + flake homeManagerModules + README