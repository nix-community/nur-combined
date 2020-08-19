{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.shell-environments;
  makeDevEnv = pkgs.callPackage ../../pkgs/build-support/makeDevEnv { };
in {

  options.programs.shell-environments = {
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
            extraPackages = with pkgs; [ vim nano ]; # Add emacs (or ed) in here if you want to
            bashrc = \'\'
              export EDITOR=vi
              export VISUAL=vi
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
          bashrc = \'\'
            # You can set up your environment further here
            alias sl="sl -F -10"
          \'\';
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
        packages = extraPackages ++ cfg.modules.base.extraPackages
          ++ (concatLists (map getModulePackages include));
        bashrc = bashrc + cfg.modules.base.bashrc
          + (concatStringsSep "\n" (map getModuleBashrc include));
      };
  in {
    programs.shell-environments.modules.base = mkDefault {
      # Loosely based on https://www.archlinux.org/packages/core/any/base/
      extraPackages = with pkgs; [
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
      bashrc = ''
        export PAGER=less
      '';
    };

    environment.systemPackages = map setEnv cfg.environments;
  };
}
