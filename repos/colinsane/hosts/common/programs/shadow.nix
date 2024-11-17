{ config, lib, ... }:
let
  cfg = config.sane.programs.shadow;
in
{
  config = lib.mkMerge [
    {
      sane.programs.shadow = {
        sandbox.enable = false;  #< `login` can't be sandboxed because it launches a user shell
      };
    }
    (lib.mkIf cfg.enabled {
      services.getty.loginProgram = lib.getExe' cfg.package "login";
      security.pam.services.login.startSession = lib.mkForce false;  #< disable systemd integration
    })
  ];
}
