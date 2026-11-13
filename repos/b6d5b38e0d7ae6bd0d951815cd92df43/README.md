# NUR Repository of b6d5b38e0d7ae6bd0d951815cd92df43

Personal [NUR](https://github.com/nix-community/NUR) (Nix User Repository) packages and modules.

## Packages

| Package | Description |
| ------- | ----------- |
| `injectd` | A tool to inject custom boot messages into the console during systemd boot. |

## Usage

Add NUR to your Nix / NixOS configuration according to the [NUR installation guide](https://github.com/nix-community/NUR#installation).

### Install `injectd`

```nix
environment.systemPackages = [
  config.nur.repos.b6d5b38e0d7ae6bd0d951815cd92df43.injectd
];
```

### Use NixOS Module

```nix
imports = [
  config.nur.repos.b6d5b38e0d7ae6bd0d951815cd92df43.nixosModules.injectd
];

services.injectd = {
  enable = true;
  mode = "matrix"; # Options: nsfw, matrix, custom
};
```
