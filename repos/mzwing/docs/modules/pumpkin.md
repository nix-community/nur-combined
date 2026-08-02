# Pumpkin NixOS and nix-darwin modules

These modules run [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin) as a system service. Pumpkin reads `pumpkin.toml` and all runtime data relative to its working directory, so the modules keep writable configuration and server state together under `services.pumpkin.dataDir`.

The NixOS module uses a systemd system service and the dedicated `pumpkin` user and group. The nix-darwin module uses a LaunchDaemon and the hidden `_pumpkin` user and group.

## NixOS usage

```nix
# configuration.nix
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.nixos.pumpkin
  ];

  services.pumpkin = {
    enable = true;

    # Defaults to /var/lib/pumpkin.
    dataDir = "/srv/pumpkin";

    settings = {
      default_level_name = "world";
      white_list = true;

      networking = {
        java = {
          enabled = true;
          address = "0.0.0.0:25565";
          motd = "A Pumpkin server managed by NixOS";
        };
        bedrock.enabled = false;
        rcon = {
          enabled = true;
          address = "127.0.0.1:25575";
        };
      };
    };

    secretSettingsFile = config.sops.secrets.pumpkin-settings.path;

    whitelist = {
      Steve = "8667ba71-b85a-4004-af54-457a9734eed7";
    };

    env = {
      RUST_BACKTRACE = "1";
    };
  };

  # Open only the ports enabled in services.pumpkin.settings.
  networking.firewall.allowedTCPPorts = [25565];
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.nixosModules.pumpkin` instead.

Control the service with:

```console
$ sudo systemctl restart pumpkin.service
$ sudo journalctl -u pumpkin.service -f
```

## nix-darwin usage

```nix
# configuration.nix
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.darwin.pumpkin
  ];

  services.pumpkin = {
    enable = true;

    # Defaults to /var/lib/pumpkin.
    dataDir = "/var/lib/pumpkin";

    # The defaults are 536. Override both if they conflict locally.
    uid = 536;
    gid = 536;

    settings = {
      default_level_name = "world";
      white_list = true;
      networking = {
        java = {
          enabled = true;
          address = "0.0.0.0:25565";
          motd = "A Pumpkin server managed by nix-darwin";
        };
        bedrock.enabled = false;
      };
    };

    secretSettingsFile = config.sops.secrets.pumpkin-settings.path;

    whitelist = {
      Steve = "8667ba71-b85a-4004-af54-457a9734eed7";
    };

    env.RUST_BACKTRACE = "1";
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.darwinModules.pumpkin` instead.

The default launchd label is `org.nixos.pumpkin`. Control the daemon and follow its logs with:

```console
$ sudo launchctl kickstart -k system/org.nixos.pumpkin
$ tail -f /var/lib/pumpkin/pumpkin.out.log /var/lib/pumpkin/pumpkin.err.log
```

The log paths follow `services.pumpkin.dataDir` when it is changed.

## Settings and secrets

The keys in `settings` are passed directly to Pumpkin and are not validated against a module-maintained schema. New upstream TOML keys can therefore be used without changing the module.

`settings` and `env` are written to the Nix store and must not contain secrets. Use `secretSettingsFile` for sensitive TOML values. For example, a file managed by sops-nix or agenix can contain:

```toml
[networking.rcon]
password = "replace-me"

[networking.proxy.velocity]
secret = "replace-me"
```

The external file is read only when the service starts and is merged after `settings`, so it takes precedence without its source contents entering the Nix store. Ensure that it is readable by the `pumpkin` user on NixOS or `_pumpkin` on nix-darwin (for example, set the corresponding sops-nix secret owner). Pumpkin has only one configuration file, however, so merged secrets exist as plaintext in `${services.pumpkin.dataDir}/pumpkin.toml`. The service uses a `0077` umask, and the merge helper sets the file mode to `0600`.

## Writable configuration

Pumpkin fills missing defaults into `pumpkin.toml` and writes the file back. The modules therefore do not create a read-only store symlink. Before each start they:

1. preserve values previously written by Pumpkin;
2. remove paths managed by the previous system configuration;
3. recursively apply the current `settings` and then `secretSettingsFile`;
4. atomically write the result and record only managed key paths in `.pumpkin-nix-managed.json`.

An existing `pumpkin.toml` is copied once to `pumpkin.toml.stateful` when the system module first takes control. Removing a value from `settings` makes that path unmanaged, so Pumpkin may restore its current default. In particular, changing or removing a world seed can affect world generation. Back up `dataDir` before changing world-related settings.

## Whitelist modes

- `whitelist = null` (the default) leaves `data/whitelist.json` under Pumpkin's and in-game commands' control.
- An attribute set declares the complete whitelist. An empty set declares an empty whitelist. Existing state is backed up before the first takeover and restored when the option is changed back to `null`.

Whitelist bookkeeping is stored in `data/.pumpkin-nix-whitelist.json`. The option manages only the JSON file; enable and enforce the whitelist through Pumpkin's own keys in `settings`.

## Firewall configuration

The modules intentionally do not infer firewall rules from schema-agnostic Pumpkin settings. Open the Java TCP port and any enabled Bedrock, Query, RCON, or plugin ports in NixOS or macOS firewall configuration yourself.

## Migration from Home Manager

This is a fresh system-service deployment. The default data directory is `/var/lib/pumpkin`; the modules do not read `~/.local/share/pumpkin`, migrate `.pumpkin-home-manager-*` bookkeeping, copy or change ownership of old data, or remove the old user service.

Before enabling the system module, back up any existing server and disable the old Home Manager service. Any manual reuse or transfer of old data, including ownership changes for the dedicated service account, is the administrator's responsibility.

## Supported systems

The default package currently supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.
