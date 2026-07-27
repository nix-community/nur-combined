{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.shell.gnupg;
in
{
  options.modules.shell.gnupg = {
    enable = mkEnableOption "enable gnupg";
  };
  config = mkIf cfg.enable {
    environment = {
      # variables.GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
      systemPackages = [ pkgs.gnupg ];
    };
  };
}
