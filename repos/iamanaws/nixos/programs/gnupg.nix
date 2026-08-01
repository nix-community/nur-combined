{
  config,
  lib,
  ...
}:

lib.mkIf config.device.openpgp.enable {
  programs.yubikey-manager.enable = true;
  programs.gnupg.agent.enable = true;
}
