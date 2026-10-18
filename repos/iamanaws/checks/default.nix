{
  pkgs,
  inputs,
  hostRegistry,
}:
let
  inherit (pkgs) lib;
in
{
  home-manager =
    assert import ./home-manager.nix { inherit inputs hostRegistry lib; };
    pkgs.runCommand "home-manager-output-checks" { } ''
      touch "$out"
    '';
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  dmenu-wpctl = pkgs.callPackage ../pkgs/dmenu-wpctl/package.nix { };
  dunst-scripts =
    pkgs.runCommand "dunst-script-checks"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          procps
          shellcheck
        ];
      }
      ''
        shellcheck -s bash ${../home/users/iamanaws/config/dunst/scripts}/*.sh
        bash ${./dunst.sh} ${../home/users/iamanaws/config/dunst/scripts}
        touch "$out"
      '';
}
