{ config, lib, pkgs, ...}:
let
  sources = import ../../dirtyFlake.nix;
in
{
  options.nixExperimental.enable = lib.mkEnableOption "wether to set up the experimental version of nix";
  config = lib.mkIf config.nixExperimental.enable {
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
