{ config
, lib
, pkgs
, ...
}:

with lib;

let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  cfg = config.programs.gita;
in

{
  options.programs.gita = {
    enable = mkEnableOption "Manage many git repos with sanity";

    repos = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { "nixpkgs" = "/home/yoctocell/.local/src/nixpkgs"; };
      description = "List of names and a corresponding path.";
    };
  };

  config = mkIf.cfg.enable {
    home.packages = [ pkgs.gitAndTools.gita ];
    home.file.".config/gita/repos_path".text = concatStringsSep "\n"
      collect (mapAttrs (name: value: value + "," + name) repos);
    # home.file.".config/gita/repos_path".text = let
    #   line = repos:
    #     let
    #       paths = collect (mapAttrs (name: value: value + "," + name) repos);
    #     in
    #       concatStringsSep "\n" paths;
    # in
    #   line cfg.repos;
  };
}
