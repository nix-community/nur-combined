{ config, pkgs, inputs, ... }:

  # VDHCoApp testing
  #vdhcoapp_testing = with pkgs; [
  #  chromium google-chrome vivaldi
  #];

let
  inherit (inputs) self;
  general-lib = import "${self}/lib" { inherit inputs; };
  inherit (general-lib) generateFirejailWrappedBinaryConfig;

in {
  imports = [
    ./common.nix
    ./profiles/workstation.nix
  ];

  programs.firejail.wrappedBinaries.stremio = generateFirejailWrappedBinaryConfig { pkg = pkgs.stremio; pkg_name = "stremio"; enable_desktop = true; desktop_file_name = "smartcode-stremio"; };
}
