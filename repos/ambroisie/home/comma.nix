{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.comma;
in
{
  options.my.home.comma = with lib; {
    enable = my.mkDisableOption "comma configuration";

    pkgsFlake = mkOption {
      type = types.str;
      default = "pkgs";
      example = "nixpkgs";
      description = ''
        Which flake from the registry should be used with
        <command>nix shell</command>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ambroisie.comma
    ];

    home.sessionVariables = {
      COMMA_PKGS_FLAKE = cfg.pkgsFlake;
    };
  };
}
