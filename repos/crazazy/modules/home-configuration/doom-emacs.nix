{ config, pkgs, lib, ... }:
let
  inherit (import ../../nix/sources.nix) nix-doom-emacs;
  doom-emacs = pkgs.callPackage nix-doom-emacs;
in
with lib;
{
  options.doom-emacs-config = {
    enable = mkEnableOption "Doom Emacs";
    doomd = mkOption {
      type = types.path;
      default = "${nix-doom-emacs}/test/doom.d";
      example = ''''${builtins.getEnv "HOME"}/doom.d'';
      description = ''
        location of the doom.d directory
      '';
    };
  };

  config = mkIf config.doom-emacs-config.enable {
    home.file.".emacs.d/init.el".text = ''
      (load "default.el")
    '';
    home.packages = [
      (doom-emacs {
        doomPrivateDir = config.doom-emacs-config.doomd;
      })
    ];
  };
}
