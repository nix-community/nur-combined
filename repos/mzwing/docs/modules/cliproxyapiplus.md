# CLIProxyAPIPlus NixOS and nix-darwin modules

These modules run [CLIProxyAPIPlus](https://github.com/kaitranntt/CLIProxyAPIPlus) as a system service. The writable configuration, authentication data, plugins, logs, and other runtime state live under `services.cliproxyapiplus.dataDir`.

The NixOS module uses a systemd system service and the dedicated `cliproxyapiplus` user and group. The nix-darwin module uses a LaunchDaemon and the hidden `_cliproxyapiplus` user and group.

## NixOS usage

```nix
# configuration.nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.nixos.cliproxyapiplus
  ];

  services.cliproxyapiplus = {
    enable = true;

    # Defaults to /var/lib/cliproxyapiplus.
    dataDir = "/srv/cliproxyapiplus";

    settings = {
      host = "localhost";
      port = 8317;
      auth-dir = "~/.cli-proxy-api";
      api-keys = [
        "replace-me"
      ];
      remote-management = {
        allow-remote = false;
        disable-control-panel = false;
        panel-github-repository = "https://github.com/kaitranntt/Cli-Proxy-API-Management-Center";
      };
      routing.strategy = "round-robin";
    };

    env.EXAMPLE = "example";
    extraArgs = ["--local-model"];
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.nixosModules.cliproxyapiplus` instead.

Control the service with:

```console
$ sudo systemctl restart cliproxyapiplus.service
$ sudo journalctl -u cliproxyapiplus.service -f
```

The module does not open firewall ports automatically. Open the configured listen port yourself if remote clients need access.

## nix-darwin usage

```nix
# configuration.nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.darwin.cliproxyapiplus
  ];

  services.cliproxyapiplus = {
    enable = true;

    # Defaults to /var/lib/cliproxyapiplus.
    dataDir = "/var/lib/cliproxyapiplus";

    # The defaults are 537. Override both if they conflict locally.
    uid = 537;
    gid = 537;

    settings = {
      host = "localhost";
      port = 8317;
      auth-dir = "~/.cli-proxy-api";
      api-keys = [
        "replace-me"
      ];
      remote-management = {
        allow-remote = false;
        disable-control-panel = false;
        panel-github-repository = "https://github.com/kaitranntt/Cli-Proxy-API-Management-Center";
      };
      routing.strategy = "round-robin";
    };

    env.EXAMPLE = "example";
    extraArgs = ["--local-model"];
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.darwinModules.cliproxyapiplus` instead.

The default launchd label is `org.nixos.cliproxyapiplus`. Control the daemon and follow its logs with:

```console
$ sudo launchctl kickstart -k system/org.nixos.cliproxyapiplus
$ tail -f /var/lib/cliproxyapiplus/cliproxyapiplus.out.log \
    /var/lib/cliproxyapiplus/cliproxyapiplus.err.log
```

The log paths follow `services.cliproxyapiplus.dataDir` when it is changed.

## Settings and writable configuration

The module writes the schema-agnostic `settings` attribute set as YAML. It does not enumerate or validate CLIProxyAPIPlus-specific keys, so new upstream settings can be used without changing the module.

CLIProxyAPIPlus and its management API update `config.yaml` in place. The modules therefore do not create a read-only Nix store symlink. Before every start they:

1. preserve values not managed by Nix;
2. remove paths managed by the previous system configuration;
3. recursively apply the current `settings`;
4. atomically write the result and record only the currently managed leaf paths in `.cliproxyapiplus-nix-managed.json`.

Lists, scalar values, and empty mappings are managed as complete values. Non-empty mappings are merged recursively. A value changed through the management API persists if its path is not present in `settings`; a currently declared value is restored from Nix at the next service start.

An existing `config.yaml` is copied once to `config.yaml.stateful` when the system module first takes control. Removing a value from `settings` removes that formerly managed path on the next start, allowing CLIProxyAPIPlus defaults or later management API changes to take over.

The runtime configuration and bookkeeping files use mode `0600`; the service uses a `0077` umask.

## API keys and other secrets

API keys are ordinary schema-agnostic settings:

```nix
services.cliproxyapiplus.settings.api-keys = [
  "key-1"
  "key-2"
];
```

The module intentionally provides no separate API key file or secret settings file. All values in `settings`, `env`, and `extraArgs` enter the Nix store. API keys and other secrets declared there are therefore visible to users that can read the corresponding store paths. They also exist as plaintext in `${services.cliproxyapiplus.dataDir}/config.yaml`, protected only by the service directory ownership, the `0077` umask, and file mode `0600`.

Values written directly through CLIProxyAPIPlus's management API can remain outside the Nix store as long as their paths are not also declared in `settings`.

## Runtime data

`dataDir` is the dedicated account's home and the process working directory. With the upstream default `auth-dir = "~/.cli-proxy-api"`, authentication data therefore resides in `${services.cliproxyapiplus.dataDir}/.cli-proxy-api`. Relative plugin and log paths are also resolved from the service working directory.

The module fixes the configuration path to `${services.cliproxyapiplus.dataDir}/config.yaml` and owns the `--config` command-line option. `extraArgs` cannot contain `-config`, `--config`, or their `=VALUE` forms.

## Migration from Home Manager

This is a fresh system-service deployment. The modules do not read, copy, delete, or change ownership of the old `~/.config/cliproxyapiplus/config.yaml`, `~/.cli-proxy-api`, Home Manager bookkeeping, or user service.

Before enabling the system module:

1. stop and disable the old Home Manager user service;
2. back up the old writable configuration and authentication data;
3. copy only the state you intend to reuse into the new `dataDir`;
4. update absolute paths in the copied configuration; and
5. set ownership for `cliproxyapiplus:cliproxyapiplus` on NixOS or `_cliproxyapiplus:_cliproxyapiplus` on nix-darwin.

Do not enable both deployments against the same writable files. Any transfer and ownership changes remain the administrator's responsibility.

## Supported systems

The default package currently supports `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.
