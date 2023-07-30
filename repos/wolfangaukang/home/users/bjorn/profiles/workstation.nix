{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) concatStringsSep;
  inherit (inputs) self;
  #local_lib = import "${self}/lib" { inherit inputs; };
  #inherit (local_lib) generateFirejailWrappedBinaryConfig;
  #fj-profiles.spotify = pkgs.fetchurl {
  #  url = "https://github.com/netblue30/firejail/blob/master/etc/profile-m-z/spotify.profile";
  #  hash = "";
  #};

in {
  services.syncthing.enable = true;

  programs.ssh = {
    enable = true;
    matchBlocks =
      let
        user = "marx";
        hellfireIPBase = "10.11.12";

      in {
        surtsey = {
          inherit user;
          hostname = concatStringsSep "." [ hellfireIPBase "203"];
          identityFile = ["${config.home.homeDirectory}/.ssh/Keys/devices/surtsey"];
        };
        grimsnes = {
          inherit user;
          hostname = concatStringsSep "." [ hellfireIPBase "112"];
          identityFile = ["${config.home.homeDirectory}/.ssh/Keys/devices/servers"];
        };
      };
  };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    #gnupg.home = "${config.home.homeDirectory}/.gnupg";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."github_pat/nixpkgs-review" = {
      mode = "0777";
      path = "${config.home.homeDirectory}/.nixpkgs-review";
    };
  };

  #programs.firejail.wrappedBinaries.spotify = generateFirejailWrappedBinaryConfig { pkg = pkgs.spotify; pkg_name = "spotify"; enable_desktop = true; };
}
