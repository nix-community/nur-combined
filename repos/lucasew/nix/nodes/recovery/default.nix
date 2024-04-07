{
  pkgs,
  modulesPath,
  lib,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../gui-common
  ];

  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    plymouth = {
      enable = true;
      theme = "breeze";

      logo = pkgs.stdenv.mkDerivation {
        name = "out.png";
        dontUnpack = true;
        src = pkgs.fetchurl {
          url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/skyrim.svg";
          sha256 = "sha256-l0dPfNdOxOpty+kJfwyC7R26Xv4R7IkleCKkOQFN9SY=";
        };
        nativeBuildInputs = with pkgs; [ inkscape ];
        buildPhase = ''
          inkscape --export-type="png" $src -o wallpaper.png -w 150 -h 210 -o wallpaper.png
        '';
        installPhase = ''
          install -Dm0644 wallpaper.png $out
        '';
      };
    };
  };
  networking = {
    hostId = "2c6b15e1";
    hostName = "recovery-iso";
    wireless.enable = false;
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "lucasew";
  };

  system.stateVersion = "22.05"; # Did you read the comment?

  virtualisation.virtualbox = {
    host.enable = false;
    guest.enable = true;
  };
}
