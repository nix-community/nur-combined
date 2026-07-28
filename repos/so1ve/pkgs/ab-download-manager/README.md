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
    inputs.nur.repos.so1ve.homeModules.ab-download-manager
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
