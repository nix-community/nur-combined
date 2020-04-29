{ pkgs, ... }:

let
  nur = import (builtins.fetchTarball
    "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
in {
  home = {
    packages = with pkgs; [ nur.repos.xe.zathura ];

    file.".config/zathura/zathurarc".source = ./zathurarc;
  };
}
