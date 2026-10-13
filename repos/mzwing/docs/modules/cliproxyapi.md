# CLIProxyAPI nix-darwin module

This module runs [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) as a LaunchDaemon. It is the nix-darwin counterpart of the NixOS `services.cliproxyapi` module in nixpkgs and takes the same `settings`, so one configuration can serve both platforms. NixOS hosts use the nixpkgs module directly.

## Usage

```nix
# configuration.nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.darwin.cliproxyapi
  ];

  services.cliproxyapi = {
    enable = true;

    settings = {
      server.host = "127.0.0.1";
      access.api-keys = [{_secret = "/run/agenix/cliproxyapi-api-key";}];
      management.secret-key._secret = "/run/agenix/cliproxyapi-management-key";
    };
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.darwinModules.cliproxyapi` instead.

`settings` is written to `/var/lib/cliproxyapi/config.yaml` at every start, so changes made through the management API last only until the next restart. Each `_secret` value is replaced with the contents of that file. The NixOS module hands secrets over as systemd credentials, but launchd has nothing similar, so here the `_cliproxyapi` service account must be able to read the files itself.

The daemon runs as the hidden `_cliproxyapi` user and keeps all of its state, OAuth tokens included, in `/var/lib/cliproxyapi`. Override `services.cliproxyapi.uid` and `gid` if the defaults clash with an existing account.

Control the daemon and follow its logs with:

```console
$ sudo launchctl kickstart -k system/org.nixos.cliproxyapi
$ tail -f /var/lib/cliproxyapi/cliproxyapi.out.log /var/lib/cliproxyapi/cliproxyapi.err.log
```
