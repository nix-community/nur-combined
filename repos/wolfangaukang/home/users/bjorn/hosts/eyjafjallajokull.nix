{ config, pkgs, inputs, ... }:

let
  inherit (inputs) self;
  # FIXME: need to learn how to create profiles on Firejail
  #fj-profiles.stremio = pkgs.fetchurl {
  #  url = "";
  #  hash = "";
  #};
  #general-lib = import "${self}/lib" { inherit inputs; };
  #inherit (general-lib) generateFirejailWrappedBinaryConfig;
  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

in {
  imports = [
    ../default.nix
    ../profiles/workstation.nix
  ];

  home.packages = with pkgs; [
    aegisub
    burpsuite
    stremio
  ];
  #programs.firejail.wrappedBinaries.stremio = generateFirejailWrappedBinaryConfig { pkg = pkgs.stremio; pkg_name = "stremio"; enable_desktop = true; desktop_file_name = "smartcode-stremio"; };
}
