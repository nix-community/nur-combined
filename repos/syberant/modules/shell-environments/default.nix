{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shell-environments;
  makeDevEnv = pkgs.callPackage ../../pkgs/build-support/makeDevEnv { };
in {

  options.programs.shell-environments = {
    base = mkOption {
      type = types.listOf types.package;
      # Loosely based on https://www.archlinux.org/packages/core/any/base/
      default = with pkgs; [
        # Collections of utilities
        coreutils
        utillinux
        procps
        psmisc

        # Gnu programs
        findutils
        gnugrep
        gnused
        gawk

        # Compression libraries
        bzip2
        gzip
        gnutar
        xz

        # Other
        file

        # Not based on arch linux base group
        less
        vim
        which
        sudo
        man
      ];
      description = "Packages included in EVERY environment.";
    };

    modules = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            extraPackages = mkOption {
              type = listOf package;
              default = [ ];
            };
            bashrc = mkOption {
              type = str;
              default = "";
            };
          };
        });
      default = { };
      example = ''
        {
          base-editors = {
            extraPackages = with pkgs; [ vi nano ]; # Add emacs in here if you want to
            bashrc = \'\'
              EDITOR=vi
              VISUAL=vi
            \'\';
          };
        }
      '';
      description = "Composable modules able to be used in `environments`.";
    };

    environments = mkOption {
      type = with types;
        listOf (submodule {
          options = {
            name = mkOption { type = str; };
            extraPackages = mkOption {
              type = listOf package;
              default = [ ];
            };
            bashrc = mkOption {
              type = str;
              default = "";
            };
            include = mkOption {
              type = listOf str;
              default = [ ];
            };
          };
        });
      default = [ ];
      example = ''
        [{
          name = "fluff";
          extraPackages = with pkgs; [ neofetch cmatrix sl ];
          include = [ "base-editors" ];
        }]
      '';
      description = "The environments to create shortcuts for.";
    };
  };

  config = let
    getModulePackages = id: cfg.modules.${id}.extraPackages;
    getModuleBashrc = id: cfg.modules.${id}.bashrc;
    setEnv = { name, extraPackages, bashrc, include }:
      makeDevEnv {
        inherit name;
        packages = cfg.base ++ extraPackages
          ++ (concatLists (map getModulePackages include));
        bashrc = bashrc + (concatStringsSep "\n" (map getModuleBashrc include));
      };
  in { environment.systemPackages = map setEnv cfg.environments; };
}
