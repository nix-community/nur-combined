# AB Download Manager

## Install

With NUR:

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

With the repository flake:

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

## Home Manager

With NUR:

```nix
{
  imports = [
    pkgs.nur.repos.so1ve.modules.homeManager.ab-download-manager
  ];

  programs.ab-download-manager.enable = true;
}
```

With the repository as a flake input:

```nix
{
  imports = [
    inputs.so1ve-nur.homeModules.ab-download-manager
  ];

  programs.ab-download-manager.enable = true;
}
```

Available options:

```nix
programs.ab-download-manager = {
  enable = true;

  # null uses automatic scaling.
  uiScale = 2;

  browserIntegration.firefox = {
    enable = true;
    installExtension = true;
  };
};
```

## Overlay

```nix
nixpkgs.overlays = [
  inputs.so1ve-nur.overlays.default
];

environment.systemPackages = [
  pkgs.ab-download-manager
];
```

## Update

Update every package from the repository root:

```bash
nix run .#update
```
