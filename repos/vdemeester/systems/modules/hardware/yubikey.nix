{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.modules.hardware.yubikey;
in
{
  options = {
    modules.hardware.yubikey = {
      enable = mkEnableOption "Enable yubikey profile";
      u2f = mkOption {
        default = true;
        description = "wether to enable auth with yubkeys throguh pam using u2f";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      environment = {
        systemPackages = with pkgs; [
          yubico-piv-tool
          yubikey-personalization
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
    }
    (mkIf config.modules.desktop.enable {
      environment.systemPackages = with pkgs; [
        yubioath-flutter
      ];
    })
    (mkIf cfg.u2f {
      security.pam.u2f = {
        enable = true;
      };
    })
  ]);
}
