{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.device.openpgp.enable {
  programs.gnupg.agent.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
}
