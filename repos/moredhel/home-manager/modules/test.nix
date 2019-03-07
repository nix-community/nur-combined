{ config, pkgs, lib, ... }:
with lib;

let
  self = import ../../default.nix {};
  dir = ".local/share/applications/nix";
  cfg = config.programs.crostini;
  desktopFile = pkgs.makeDesktopItem {
    name = "one";
    desktopName = "one";
    exec = "one";
  };

in {
  options.programs.crostini = with types; {
    enable = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # home.activation.applications = self.lib.symlink "~/.nix-profile/share/applications" "~/.local/share/applications/nix";
  };
}
