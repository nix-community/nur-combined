{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.scaff;
in
{
  options = {
    programs.scaff = {
      enable = mkEnableOption "scaff";
      package = mkOption {
        type = types.package;
        default = pkgs.callPackage (builtins.fetchTarball {
          url = "https://gitlab.com/jD91mZM2/scaff/-/archive/6da3176029d167e48c2854ff93987451eb564407.tar.gz";
          sha256 = "08fskkcni78pll31q15p0a1knnmxlzd7cc4pig55pcmzqcc27akn";
        }) {};
        description = ''
          Which scaff package to use. Defaults to the latest one,
          because as I'm writing this no scaff version is in nixpkgs.
        '';
      };

      imports = mkOption {
        type = types.attrsOf (types.coercedTo types.path toString types.str);
        default = {};
        example = literalExample ''
        {
          my-local-template          = ./my-local-template.tar.gz;
          my-remote-template         = "https://example.org/my-remote-template.tar.gz";
          my-remote-template-fetched = builtins.fetchurl https://example.org/my-remote-template-built-using-nix.tar.gz;
        }
        '';
        description = ''
          The list of imported tarballs, which will be available by using `scaff <alias>`
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."scaff/config.toml".text = ''
      [imports]
      ${builtins.concatStringsSep "\n" (mapAttrsToList (name: url: "${name} = \"${toString url}\"") cfg.imports)}
    '';
  };
}
