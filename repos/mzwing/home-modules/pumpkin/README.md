# Pumpkin Home Manager module

This module runs [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin) as a user service. Pumpkin reads `pumpkin.toml` and all of its runtime data relative to its working directory, so the module keeps a writable configuration and server state together under `services.pumpkin.dataDir`.

## Usage

```nix
# home.nix
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.homeManager.pumpkin
  ];

  services.pumpkin = {
    enable = true;

    # Defaults to "${config.xdg.dataHome}/pumpkin".
    dataDir = "${config.home.homeDirectory}/servers/pumpkin";

    settings = {
      default_level_name = "world";
      white_list = true;

      networking = {
        java = {
          enabled = true;
          address = "0.0.0.0:25565";
          motd = "A Pumpkin server managed by Home Manager";
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
}
```

The example keys above are passed directly to Pumpkin. They are not a schema maintained or validated by this module. New upstream TOML keys can be added to `settings` without changing the module.

Alternatively, import the module directly where the Home Manager module list is built:

```nix
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    inputs.nur.repos.mzwing.modules.homeManager.pumpkin
    ./home.nix
  ];
}
```

## Secret settings

`settings` and `env` are written to the Nix store and must not contain secrets. Use `secretSettingsFile` for sensitive TOML values. For example, a secret managed by sops-nix or agenix can contain:

```toml
[networking.rcon]
password = "replace-me"

[networking.proxy.velocity]
secret = "replace-me"
```

The external file is read only when the service starts and is merged after `settings`, so it takes precedence. Its source contents do not enter the Nix store. Pumpkin has only one configuration file, however, so the merged secrets must exist as plaintext in `${services.pumpkin.dataDir}/pumpkin.toml`. The module sets its mode to `0600` and uses a `0077` umask.

## Writable configuration

Pumpkin fills missing defaults into `pumpkin.toml` and writes the file back. The module therefore does not create a read-only store symlink. Before each start it:

1. preserves values previously written by Pumpkin;
2. removes paths managed by the previous Home Manager generation;
3. recursively applies the current `settings` and then `secretSettingsFile`;
4. atomically writes the result and records only managed key paths.

An existing `pumpkin.toml` is copied once to `pumpkin.toml.stateful` when the module first takes control. Removing a value from `settings` makes that path unmanaged; Pumpkin may then restore its current default. In particular, changing or removing a world seed can affect world generation. Back up `dataDir` before changing world-related settings.

## Whitelist modes

- `whitelist = null` (the default) leaves `data/whitelist.json` under Pumpkin's and in-game commands' control.
- An attribute set declares the complete whitelist. An empty set declares an empty whitelist. Existing state is backed up before the first takeover and is restored when the option is changed back to `null`.

The whitelist option only manages the JSON file. Enable and enforce the whitelist through Pumpkin's own keys in `settings` as appropriate for the upstream version.

## Service control

On Linux:

```console
$ systemctl --user restart pumpkin.service
$ journalctl --user -u pumpkin.service -f
```

On macOS:

```console
$ launchctl kickstart -k gui/$(id -u)/org.nix-community.home.pumpkin
$ tail -f ~/Library/Logs/Pumpkin.out.log ~/Library/Logs/Pumpkin.err.log
```

Home Manager cannot manage the host firewall portably. Open the configured Java, Bedrock, Query, RCON, or other ports in the operating system firewall yourself.
