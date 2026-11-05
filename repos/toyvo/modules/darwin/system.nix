{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ../os/users/toyvo.nix ];

  options.nixcfg.system.enable = lib.mkEnableOption "system defaults";

  config = {
    system = {
      stateVersion = 7;
      primaryUser = config.nixcfg.users.toyvo.name;
    };
    environment.systemPackages = with pkgs; [
      firefox-bin
      ghostty-bin
      podman-desktop
      libreoffice-bin
      proton-pass
      protonmail-desktop
    ];
  };
}
