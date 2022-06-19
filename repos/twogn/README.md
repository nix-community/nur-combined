# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

## about this repository
I requested [nixpkgs](https://github.com/nixos/nixpkgs/) to add platformio extension for vscode but it's not merged yet. Maybe there's something not convenient or againsting philosophy but I seriously need this. that's why I created this repo.

To use platformio-ide package, you need to add the following lines to your home-manager configuration. It is ~/.config/nixpkgs/home.nix by default, and is accessible by executing `home-manager edit`.

For now, extension `cpp-tools` is only available for 64bit linux and platformio doesn't work without it. Therefore, platformio extension works only on `x64_86_linux`.

```nix
{
  nixpkgs = {
    config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };
  programs.vscode = {
    enable = true;
    extensions = with pkgs;[
      vscode-extensions.ms-vscode.cpptools
      nur.repos.twogn.vscode-extensions.platformio.platformio-ide
      # for more informations about declaring vscode extensions, please check out the wiki written by nix community: https://nixos.wiki/wiki/Visual_Studio_Code
    ];
  };
}
```


## disclaimers 
codes under pkgs/vscode-extensions were copied from original nixpkgs repository. and then I modified some lines/directories in it. If it is violating some rules, please tell me. I'll delete this immediately.
