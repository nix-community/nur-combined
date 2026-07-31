# CLIProxyAPIPlus Home Manager module

Usage:

```nix
# home.nix
{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.homeManager.cliproxyapiplus
  ];

  programs.cliproxyapiplus = {
    enable = true;

    configPath =
      "${config.xdg.configHome}/cliproxyapiplus/config.yaml";

    apiKeysFile = config.sops.secrets.cliproxyapiplus-api-keys.path;

    env = {
      EXAMPLE = "example";
    };

    settings = {
      host = "localhost";
      port = 8317;
      auth-dir = "${config.home.homeDirectory}/.cli-proxy-api";
      remote-management = {
        allow-remote = false;
        disable-control-panel = false;
        panel-github-repository = "https://github.com/kaitranntt/Cli-Proxy-API-Management-Center";
      };
      routing.strategy = "round-robin";
    };

    extraArgs = [];
  };
}
```

Alternatively, import it directly where the Home Manager module list is built, without passing `inputs` into `home.nix`:

```nix
# flake.nix
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    inputs.nur.repos.mzwing.modules.homeManager.cliproxyapiplus
    ./home.nix
  ];
}
```

Restart the service:

```bash
$ systemctl --user restart cliproxyapiplus.service
```

On macOS:

```bash
$ launchctl kickstart -k gui/$(id -u)/org.nix-community.home.cliproxyapiplus
```
