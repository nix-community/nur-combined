{ pkgs, flakeRoot, ... }:
let
  scripts = flakeRoot + "/home/users/iamanaws/config/dunst/scripts";
in
pkgs.runCommand "nixos-home-users-iamanaws-config-dunst"
  {
    nativeBuildInputs = with pkgs; [
      bash
      coreutils
      procps
      shellcheck
    ];
  }
  ''
    shellcheck -s bash ${scripts}/*.sh
    bash ${./dunst.sh} ${scripts}
    touch "$out"
  ''
