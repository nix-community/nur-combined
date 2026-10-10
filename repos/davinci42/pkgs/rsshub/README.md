# RSSHub

Source package based on [nixpkgs PR #572172](https://github.com/NixOS/nixpkgs/pull/572172)
and the [upstream flake](https://github.com/DIYgod/RSSHub/blob/master/flake.nix).
Uses the caller's Node.js 24 and pnpm 10, with offline route generation adapted
for the current registry. Licensed under AGPL-3.0-only, not the upstream flake's
outdated MIT declaration. Supports x86_64-linux, aarch64-linux and aarch64-darwin.

## Usage

```sh
nix build -f . rsshub
LISTEN_INADDR_ANY=0 PORT=1201 ./result/bin/rsshub
```

Keep the existing nixpkgs NixOS module and replace only its package:

```nix
{ pkgs, config, ... }:
{
  services.rsshub = {
    enable = true;
    package = (import /path/to/nur-packages { inherit pkgs; }).rsshub;
    openFirewall = false;
    redis.enable = true;
    settings = {
      LISTEN_INADDR_ANY = true;
      PORT = 1201;
    };
    secretFiles = [ config.age.secrets.rsshub-access.path ];
  };
}
```

No additional module import is needed. Existing Redis, `settings`, `secretFiles`
and reverse-proxy configuration remain applicable. `LISTEN_INADDR_ANY = true`
binds all interfaces; use `false` for a loopback-only reverse-proxy backend.
Keep access keys and route credentials in runtime secret files, not Nix strings.
Browser-dependent routes need a separately configured browser; none is bundled.

## Maintenance and tests

```sh
nix-shell --run 'just update rsshub'
nix-shell --run 'just check rsshub'
```

Release detection and ordering use `nix-update --use-github-releases`; source
and pnpm dependency hashes are refreshed by the existing isolated update flow.
Its `passthru.updateScript` pins the release-selection flags; `passthru.tests`
provides packaging checks. Shared source and all-platform pnpm hashes are
refreshed on the current host.
Old same-day tags containing only a commit suffix follow nix-update's ordering,
not commit chronology. Newer tags also include an upstream build number.

Review `package.json`, `pnpm-lock.yaml`, `lib/config.ts`, `lib/index.ts`,
`lib/registry.ts`, `lib/registry-helpers.ts` and the access-control middleware
when updating. Configuration reference: <https://docs.rsshub.app/deploy/config>.
The upstream flake is a reference, not a runtime dependency.

Checks build the package, evaluate compatibility with the nixpkgs service,
and start an isolated instance over a temporary Unix socket. They verify
health, static assets, the generated route registry and access-key enforcement.
No existing services, data or secrets are used. Upstream unit suites, external
feed sources, browser routes and NixOS VM tests are not run.
