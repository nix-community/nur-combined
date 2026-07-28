# AB Download Manager

## Package

### NUR

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

### Flake

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

## Home Manager

### NUR

```nix
{
  imports = [
    inputs.nur.repos.so1ve.homeModules.ab-download-manager
  ];

  programs.ab-download-manager.enable = true;
}
```

### Repository flake

```nix
{
  imports = [
    inputs.so1ve-nur.homeModules.ab-download-manager
  ];

  programs.ab-download-manager.enable = true;
}
```

## Options

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
