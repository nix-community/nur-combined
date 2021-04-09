{ config, lib, pkgs, ...}:
{
  options.nixExperimental.enable = lib.mkEnableOption "wether to set up the experimental version of nix";
  config = lib.mkIf config.nixExperimental.enable {
    nix.package = pkgs.nixFlakes;
    environment.shellAliases.nix = "nix --experimental-features 'nix-command flakes'";
  };
}
