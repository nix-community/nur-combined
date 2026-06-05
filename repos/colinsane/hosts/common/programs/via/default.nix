# - <https://nixos.wiki/wiki/Qmk>
# via lets one change the keymap on a QMK keyboard without reflashing
# - intro: <https://www.caniusevia.com/docs/specification>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.via;
in
{
  sane.programs.via = {
    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;
  };
  services.udev.packages = lib.mkIf cfg.enabled [ cfg.package pkgs.qmk-udev-rules ];
  services.udev.extraRules = lib.mkIf cfg.enabled ''
    # ZSA Ergodox Glow
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="4976", TAG+="uaccess"
  '';
}
