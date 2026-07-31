# AB Download Manager

Install the package with NUR:

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

Or use the Home Manager module:

```nix
{
  imports = [
    inputs.nur.repos.so1ve.homeModules.ab-download-manager
  ];

  programs.ab-download-manager.enable = true;
}
```

Optional scaling and Firefox integration:

```nix
programs.ab-download-manager = {
  enable = true;
  uiScale = 2;
  browserIntegration.firefox = {
    enable = true;
    installExtension = true;
  };
};
```
