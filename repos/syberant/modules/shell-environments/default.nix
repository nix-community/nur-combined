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
            include = mkOption {
              type = listOf str;
              default = [ ];
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
            excludeBase = mkOption {
              type = bool;
              default = false;
            };
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
    # Get a set with all `include`d modules.
    # It should look like this:
    # {
    #   base = { bashrc = ...; extraPackages = ...; include = ...; };
    #   ...
    # }
    getIncludes = start: finished:
      foldl (acc: id:
        if hasAttr id acc then
          acc
        else
          getIncludes cfg.modules.${id}.include
          (acc // { ${id} = cfg.modules.${id}; })) finished start;
    setEnv = { name, excludeBase, extraPackages, bashrc, include }:
      let
        # Recursively get all modules that should be included.
        # Data structure explained at `getIncludes`.
        includes =
          getIncludes (optionals (!excludeBase) [ "base" ] ++ include) { };

        includePackagesList =
          mapAttrsToList (id: content: content.extraPackages) includes;
        allPackages = extraPackages ++ concatLists includePackagesList;

        includeBashrcList =
          mapAttrsToList (id: content: content.bashrc) includes;
        allBashrc = (concatStringsSep "\n" includeBashrcList) + bashrc;
      in makeDevEnv {
        inherit name;
        packages = allPackages;
        bashrc = allBashrc;
      };
  in {
    programs.shell-environments.modules.base = {
      # Loosely based on https://www.archlinux.org/packages/core/any/base/
      extraPackages = with pkgs;
        mkDefault [
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
      bashrc = mkDefault ''
        export PAGER=less
      '';
    };

    environment.systemPackages = map setEnv cfg.environments;
  };
}
