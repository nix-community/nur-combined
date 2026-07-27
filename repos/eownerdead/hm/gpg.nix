{ lib, config, ... }:
{
  options.eownerdead.gpg.enable = lib.mkEnableOption "Enable gpg";

  config = lib.mkIf config.eownerdead.gpg.enable {
    programs.gpg = {
      enable = true;
      homedir = lib.mkIf config.eownerdead.imperm.enable "${config.eownerdead.imperm.dataHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };
}
