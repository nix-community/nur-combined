username:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) optional;
in
{
  users.mutableUsers = false;
  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$6$3mI6lDngcB2nrJx5$IG1j2hHtg0xhvrcFSO99zW1b8Lil4rgWLjgppTe3ALA1ftfLmDnHdAeuhtI/Zc0AwvsNThQIWxtAu/gHN1gfD1";
    shell = pkgs.fish;
    extraGroups =
      [
        "wheel"
        "input"
        "audio"
        "video"
      ]
      ++ optional config.networking.networkmanager.enable "networkmanager"
      ++ optional config.programs.adb.enable "adbusers"
      ++ optional config.virtualisation.libvirtd.enable "libvirtd";
  };

  home-manager.users."${username}" = {
    imports = [
      ./common
      ./${config.networking.hostName}
    ];
    home.username = username;
    home.homeDirectory = "/home/${username}";
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
    home.stateVersion = config.system.stateVersion;
  };
}
