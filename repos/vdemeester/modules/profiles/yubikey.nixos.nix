{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.yubikey;
in
{
  options = {
    profiles.yubikey = {
      enable = mkOption {
        default = false;
        description = "Enable yubikey profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        yubico-piv-tool
        yubikey-personalization
        yubioath-desktop
        yubikey-manager
      ];
    };
    services = {
      pcscd.enable = true;
      udev = {
        packages = with pkgs; [ yubikey-personalization ];
        extraRules = ''
          # Yubico YubiKey
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess", MODE="0660", GROUP="wheel"
          # ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
        '';
      };
    };
  };
}
