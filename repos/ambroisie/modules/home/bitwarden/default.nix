{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.bitwarden;
in
{
  options.my.home.bitwarden = with lib; {
    enable = my.mkDisableOption "bitwarden configuration";

    pinentry = mkPackageOption pkgs "pinentry" { default = [ "pinentry-tty" ]; };
  };

  config = lib.mkIf cfg.enable {
    programs.rbw = {
      enable = true;

      settings = {
        email = lib.my.mkMailAddress "bruno" "belanyi.fr";
        inherit (cfg) pinentry;
      };
    };
  };
}
