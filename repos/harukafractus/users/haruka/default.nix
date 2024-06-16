{ pkgs, config, home-manager, hm-flatpak, ... }: {
  users.users.haruka = if pkgs.stdenv.isLinux then {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "test";
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
      "wireshark"
    ];
  } else # ... Or on nix-darwin
  if pkgs.stdenv.isDarwin then {
    name = "haruka";
    home = "/Users/haruka";
  } else throw "User `haruka` is not defined";

  # Home manager stuff
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.haruka = import (
      ./home.nix
    );
  };
}