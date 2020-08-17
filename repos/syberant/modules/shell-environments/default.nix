{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shell-environments;
  makeDevEnv = pkgs.callPackage ../../pkgs/build-support/makeDevEnv { };
in {

  options.programs.shell-environments = {
    base = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ coreutils gnugrep gnused gawk ];
      description = "Packages included in EVERY environment.";
    };

    environments = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      example = ''
        [{
          name = "env-fluff";
          extraPackages = with pkgs; [ neofetch cmatrix sl ];
        }]
      '';
      description = "The environments to create shortcuts for.";
    };
  };

  config = let
    setEnv = { name, extraPackages ? [ ], include ? [ ] }:
      makeDevEnv {
        inherit name;
        packages = cfg.base ++ extraPackages;
      };
  in { environment.systemPackages = map setEnv cfg.environments; };
}
