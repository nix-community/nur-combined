{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) optional;
  username = "zzzsy";
in
{
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    hashedPassword = "$6$3mI6lDngcB2nrJx5$IG1j2hHtg0xhvrcFSO99zW1b8Lil4rgWLjgppTe3ALA1ftfLmDnHdAeuhtI/Zc0AwvsNThQIWxtAu/gHN1gfD1";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "video"
    ]
    ++ optional config.networking.networkmanager.enable "networkmanager"
    ++ optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ optional config.security.tpm2.enable "tss";
  };

  home-manager.users.${username} = {
    imports = [
      ./common
      ./${config.networking.hostName}
    ];
    home.username = username;
    home.homeDirectory = "/home/${username}";
    programs.home-manager.enable = true;
    home.stateVersion = config.system.stateVersion;
  };
}
