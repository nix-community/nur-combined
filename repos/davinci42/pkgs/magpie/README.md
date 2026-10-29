# Magpie

[Upstream](https://github.com/yetone/magpie) local AI model gateway and agent
configuration manager (`magpie`) for `x86_64-linux`, `aarch64-linux` and
`aarch64-darwin`.

Installs the headless CLI/gateway binary (`magpie-cli-*`) at `$out/bin/magpie`
on all platforms (supports `magpie serve`, `magpie web`, `magpie tui`, and all
CLI commands without GUI dependencies).

## Usage

```sh
nix build -f . magpie
```

### NixOS module (`nixosModules.magpie`)

```nix
{
  imports = [ ./modules/magpie-nixos.nix ];
  services.magpie = {
    enable = true;
    web.enable = true;
    environmentFile = "/run/secrets/magpie.env";
    settings = {
      chinaMirror = true;
      redact = true;
      noAutoUpdate = true;
    };
  };
}
```

Defaults: gateway on `127.0.0.1:3425`, user `magpie`, state under
`/var/lib/magpie`, telemetry disabled (`DO_NOT_TRACK=1`, `MAGPIE_NO_STATS=1`).

### nix-darwin module (`darwinModules.magpie`)

```nix
{
  imports = [ ./modules/magpie-darwin.nix ];
  services.magpie = {
    enable = true;
    web.enable = true;
    settings = {
      theme = "dark";
      chinaMirror = true;
      redact = true;
      noAutoUpdate = true;
    };
  };
}
```

## Settings synchronization

`services.magpie.settings` accepts any upstream `settings.json` attribute set
without locking to a static schema. On service start, `modules/magpie-configure.py`
performs tracked partial synchronization into `settings.json`:

- Keys declared in `settings` (and optional `settingsFile`) are enforced on every
  service start, preventing drift on declared options.
- Keys previously managed by Nix that are later removed from `settings` are
  automatically pruned from `settings.json` (tracked in `.nix-managed-keys.json`).
- Unmanaged keys written by Magpie at runtime (such as window dimensions, agent
  ordering or UI preferences) remain untouched and writable (`0600`).

Keep secrets such as `githubToken` or authenticated proxy URLs outside the Nix
store via `environmentFile` and `settingsFile`.

For a fixed Web UI sign-in key on either platform, set `web.keyFile` to a runtime
file containing only the raw key, not an environment variable assignment. For
example, with agenix:

```nix
services.magpie.web.keyFile = config.age.secrets.magpie-web-key.path;
```

On NixOS, systemd loads the file via `LoadCredential`, so the source may remain
root-owned with mode `0400`. On Darwin, the LaunchAgent user must be able to read
the file. The key must contain at least 16 characters from letters, digits and
`-._~`. It is read at startup, stays outside
the Nix store, and overrides `MAGPIE_WEB_KEY` from `environmentFile`. Open
`http://127.0.0.1:3430` and paste the key into the sign-in page. With `keyFile =
null` (the default), Magpie uses its existing environment or random-key behavior.

## Maintenance and tests

```sh
nix-shell
just update magpie
just check magpie
```

Checks include NixOS and nix-darwin module evaluation assertions, tracked
`settings.json` synchronization unit tests, live gateway healthcheck/API tests
and repository lint.
