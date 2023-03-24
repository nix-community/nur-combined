{ config, pkgs, ... }:
let
  steam-config = pkgs.steam.override {
    # commented out for now, might not even need this tbh
    # nativeOnly = true;
    extraPkgs = pkgs: with pkgs; [
      mono
      gtk3
      gtk3-x11
      libgdiplus
      zlib
    ];
    # withJava = true;
  };
in
{
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
  environment.systemPackages = [ steam-config.run ];
}
