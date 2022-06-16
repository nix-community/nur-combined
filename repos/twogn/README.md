# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

## about this repository
I requested [nixpkgs](https://github.com/nixos/nixpkgs/) to add platformio extension for vscode but it's not merged yet. Maybe there's something not convenient or againsting philosophy but I seriously need this. that's why I created this repo.

To use platformio-ide package, you need to add the following lines to your home-manager configuration. It is ~/.config/nixpkgs/home.nix by default, and is accessible by executing `home-manager edit`.

```nix
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in
{
  programs.vscode = {
    enable = true;
    extensions = [
      nur-no-pkgs.repos.twogn.vscode-extensions.platformio.platformio-ide
    ];
  };
}
```

## disclaimers 
codes under pkgs/vscode-extensions were copied from original nixpkgs repository. and then I modified some lines/directories in it. If it is violating some rules, please tell me. I'll delete this immediately.
