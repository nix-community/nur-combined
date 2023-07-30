{ config, pkgs, lib, inputs, ... }:

let
  inherit (inputs) self;
  #fj-profiles.discord = pkgs.fetchurl {
  #  url = "https://raw.githubusercontent.com/netblue30/firejail/master/etc/profile-a-l/discord.profile";
  #  hash = "";
  #};
  #general-lib = import "${self}/lib" { inherit inputs; };
  #inherit (general-lib) generateFirejailWrappedBinaryConfig;

in {
  imports = [
    ../default.nix
    ../profiles/workstation.nix
    ../profiles/programs/mopidy.nix
  ];

  home.persistence = {
    #"/persist/home/bjorn" = {
    #  directories = [
    #    ".aws"
    #    #".cache"
    #    ".config"
    #    ".gnupg"
    #    ".local"
    #    ".mozilla"
    #    ".ssh/keys"
    #    #".thunderbird"
    #    # TODO: Test using only .Upwork/Upwork/UserData/
    #    ".Upwork"
    #    #".vscode-oss"
    #  ];
    #  files = [
    #    ".nixpkgs-review"
    #    ".ssh/known_hosts"
    #  ];
    #};
    "/data/bjorn" = {
      directories = [
        "Aparatoj"
        "Biblioteko"
        "Bildujo"
        "Dokumentujo"
        "Ludoj"
        "Muzikujo"
        "Projektujo"
        "Screenshots"
        "Torrentoj"
        "Utilecoj"
        "VMs"
      ];
    };
  };

  # Personal Settings
  home.packages = with pkgs; [
    gimp
    musescore
    qbittorrent
  ];

  programs = {
    #firejail.wrappedBinaries.discord = generateFirejailWrappedBinaryConfig { pkg = pkgs.discord; pkg_name = "discord"; enable_desktop = true; };
    neofetch.startOnZsh = true;
  };

}
