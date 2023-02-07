{ config, pkgs, ... }: {
  services.udev.packages = [ pkgs.yubikey-personalization ];
  environment.systemPackages = with pkgs; [ libfido2 ];
}
