{ config, inputs, pkgs, ... }:

let
  inherit (inputs) self;
  local_lib = import "${self}/lib" { inherit inputs; };
  inherit (local_lib) generateFirejailWrappedBinaryConfig;

in {
  programs.firejail.wrappedBinaries.spotify = generateFirejailWrappedBinaryConfig { pkg = pkgs.spotify; pkg_name = "spotify"; enable_desktop = true; };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    #gnupg.home = "${config.home.homeDirectory}/.gnupg";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets."github_pat/nixpkgs-review" = {
      mode = "0777";
      path = "${config.home.homeDirectory}/.nixpkgs-review";
    };
  };
}
