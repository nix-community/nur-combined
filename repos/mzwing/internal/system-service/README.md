# Internal system-service abstraction

This library renders a normalized, single-process system service specification into either a NixOS systemd service or a nix-darwin LaunchDaemon. It is intended for repository modules that would otherwise repeat package installation, dedicated account creation, process configuration, and lifecycle mapping.

It deliberately does not define user-facing module options or know about a specific program.

## API

```nix
serviceLib = import ../../internal/system-service {
  inherit lib pkgs;
  # Required when calling mkNixos; use the NixOS module argument.
  systemdUtils = utils;
};

spec = serviceLib.mkSpec {
  name = "example";
  description = "Example daemon";
  packages = [cfg.package];

  process = {
    executable = lib.getExe cfg.package;
    arguments = ["--config" cfg.configFile];
    environment = cfg.env;
    workingDirectory = cfg.dataDir;
    umask = "0077";
  };

  account = {
    logicalName = "example";
    home = cfg.dataDir;
    description = "Example daemon service user";

    # Required by mkDarwin when account management is enabled.
    darwin = {
      uid = cfg.uid;
      gid = cfg.gid;
    };
  };

  lifecycle = {
    autostart = true;
    restart = "on-failure"; # "no", "always", or "on-failure"
    restartBackoffSeconds = 5;
    stopTimeoutSeconds = 90;
  };

  nixos = {
    wantedBy = null; # Defaults to multi-user.target when autostart is true.
    wants = [];
    requires = [];
    after = [];
    serviceConfig = {};
    extraConfig = {};
  };

  darwin = {
    standardOutPath = null;
    standardErrorPath = null;
    serviceConfig = {};
    extraConfig = {};
  };
};

nixosConfig = serviceLib.mkNixos spec;
darwinConfig = serviceLib.mkDarwin spec;
```

Both renderers return module configuration fragments suitable for `lib.mkMerge`. They install `packages`, validate common process properties, create the optional managed account, and define the platform service.

## Account behavior

The NixOS account defaults to `account.logicalName`. The nix-darwin account defaults to the same name prefixed with `_`. These can be overridden with `account.nixos.userName`, `account.nixos.groupName`, `account.darwin.userName`, and `account.darwin.groupName`.

Set `account.manage = false` to run as an existing account without declaring it. Set `account = null` to omit `User` and `Group` entirely.

Additional account declarations can be supplied through each platform's `userConfig` and `groupConfig` attributes.

## Semantic limits

The lifecycle mapping is intentionally small:

| Specification | NixOS | nix-darwin |
| --- | --- | --- |
| `autostart` | `wantedBy` | `RunAtLoad` |
| `restart` | `Restart` | `KeepAlive` |
| `restartBackoffSeconds` | `RestartSec` | `ThrottleInterval` |
| `stopTimeoutSeconds` | `TimeoutStopSec` | `ExitTimeOut` |
| `process.umask` | octal string | decimal plist value |

`ThrottleInterval` is launchd throttling rather than an exact equivalent of `RestartSec`. launchd restart management also implies an initial run, so the Darwin renderer rejects restart management when `autostart` is false.

Network ordering, systemd hardening, launchd log paths, socket activation, timers, and other platform-specific behavior must remain in `nixos`, `darwin`, `serviceConfig`, or `extraConfig`. The abstraction must not pretend these have portable semantics.
