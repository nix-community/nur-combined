{ config, pkgs, ... }:
let
  isAarch = pkgs.system == "aarch64-linux";
  autoLoginEnable =
    builtins.any (x: x.name == "jay") (builtins.attrValues config.users.users);
  autoLogin = if isAarch && autoLoginEnable then {
    enable = true;
    user = "jay";
  } else
    { };
in {
  services.xserver = {
    enable = true;
    displayManager = {
      inherit autoLogin;
      lightdm = {
        enable = true;
        background = pkgs.nixos-artwork.wallpapers.simple-red.gnomeFilePath;
      };
    };
    desktopManager.lxqt.enable = true;
  };
}
