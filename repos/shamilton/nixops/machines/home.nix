{ pkgs ? import <nixpkgs> {} 
, lib ? pkgs.lib
, config
, ...
}:
with pkgs;
let
  localShamilton = import /home/scott/GIT/nur-packages/default.nix {
    localUsage = true;
  };
in
rec {
  imports = [
    localShamilton.modules.hmModules.myvim
    # /home/scott/.config/user
    ./user.nix
  ];
  programs.myvim = {
    enable = true;
    enableNvimCoc = false;
  };
  home.homeDirectory = config.home-dir.home_dir;
  xdg = {
    enable = true;
    cacheHome = "${home.homeDirectory}/.local/cache";
    configHome = "${home.homeDirectory}/.config";
    dataHome = "${home.homeDirectory}/.local/share";
    mime.enable = true;
    mimeApps.enable = true;
  };
  home.packages = [
  ];

  programs.git = {
    enable = true;
    userName  = "SCOTT-HAMILTON";
    userEmail = "sgn.hamilton+github@protonmail.com";
  };

  manual.manpages.enable = false;

  home.sessionVariables = {
    EDITOR = "vim";
  };
}

