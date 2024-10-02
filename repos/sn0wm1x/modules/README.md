# SN0WM1X UR Modules

## sn0wm1x.{nixosModules,homeManagerModules}.sn0wm1x

SN0WM1X-style configuration for some programs/services. If you like some of my configurations, use it to easily enable them.

```nix
{ inputs, ...}: {
  imports = [
    # inputs.sn0wm1x.nixosModules.sn0wm1x # not yet
    ...
  ];

  home-manager.sharedModules = [
    inputs.sn0wm1x.homeManagerModules.sn0wm1x
    ...
  ];
}
```

Usually they have a simple enable option, but the configuration may vary depending on the package.

```nix
{
  programs.fastfetch.enable = true;
  programs.fastfetch.sn0wm1x = true;
}
```

## sn0wm1x.{nixosModules,homeManagerModules}.experimental

WIP modules, often placed here because I haven't tested it yet.

```nix
{ inputs, ...}: {
  imports = [
    inputs.sn0wm1x.nixosModules.experimental
    ...
  ];

  home-manager.sharedModules = [
    # inputs.sn0wm1x.homeManagerModules.experimental # not yet
    ...
  ];
}
```
