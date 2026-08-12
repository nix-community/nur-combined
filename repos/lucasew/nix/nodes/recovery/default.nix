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

  services.xserver.windowManager.i3.enable = true;

  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    zfs.forceImportRoot = false;
    plymouth = {
      enable = true;
      theme = "breeze";
      logo = pkgs.plymouthSvgLogo {
        url = "https://github.com/lucasew/nixcfg/releases/download/debureaucracyzzz/skyrim.svg";
        sha256 = "sha256-l0dPfNdOxOpty+kJfwyC7R26Xv4R7IkleCKkOQFN9SY=";
      };
    };
  };
  networking = {
    hostId = "2c6b15e1";
    hostName = "recovery-iso";
    wireless.enable = lib.mkForce false;
  };

  system.stateVersion = "22.05"; # Did you read the comment?

  virtualisation.virtualbox = {
    host.enable = false;
    guest.enable = true;
  };
}
