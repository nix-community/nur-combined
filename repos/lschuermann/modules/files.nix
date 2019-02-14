# A quick and dirty way to manage config-files with the NixOS system configuration
# This will write to your system persistently and can break things! Use at your own risk!
#
# Currently, there is no way to keep track of the created symlinks
# I have some ideas for that or may just use an overlayfs
# WORK IN PROGRESS

{ config, lib, pkgs, ... }:

with lib;

let

  pathToLabel = path: builtins.replaceStrings [ "/" "." ] [ "_" "" ] path;

  assertions = e:
  [
    { assertion = !(isNull e.src) || !(isNull e.content);
      message = ''file ${e.dest}: at least one of "src" or "content" needs to be set'';
    }
    { assertion = isNull e.src || isNull e.content;
      message = ''file ${e.dest}: "src" and "content" can't be set at the same time'';
    }
  ];


  linkSrc = e:
    if !(isNull e.content) then
      pkgs.writeText (pathToLabel e.dest) e.content
    else if hasPrefix "/nix/store" e.src then
      e.src
    else
      pkgs.writeText (pathToLabel e.dest) (builtins.readFile e.src);

  globalFile = {
    options = {
      src = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      content = mkOption {
        type = with types; nullOr string;
        default = null;
      };

      dest = mkOption {
        type = types.string;
      };
    };
  };

  userFile = {
    options = {
      src = mkOption {
        type = with types; nullOr path;
        default = null;
      };

      content = mkOption {
        type = with types; nullOr string;
        default = null;
      };

      dest = mkOption {
        type = types.string;
      };
    };
  };

in

{

  ###### interface

  options = {

    files = mkOption {
      type = with types; listOf (submodule globalFile);
      default = [];
    };

    users.users = mkOption {
      type = with types; loaOf (submodule {

        files = mkOption {
          type = with types; listOf (submodule userFile);
          default = [];
        };

      });
    };

  };


  ###### implementation

  config = {

    assertions =
      lib.flatten (map assertions config.files) ++
      (lib.flatten (lib.mapAttrsToList (name: u: map assertions u.files) config.users.extraUsers));

    system.activationScripts.symlinkGlobalFiles = {
      text = ''
        echo "files: creating symlinks..."

        ERROR=0

        ${lib.concatMapStringsSep
            "\n"
            (e: ''
              if [ -L "${e.dest}" ]; then
                # Is a symlink, overwrite it
                ln -sf "${linkSrc e}" "${e.dest}"
              elif [ -f "${e.dest}" ]; then
                echo "files: Error while creating symlink \"${e.dest}\": File in the way"
                ERROR=1
              else
                mkdir -p "$(dirname "${e.dest}")"
                ln -s "${linkSrc e}" "${e.dest}"
              fi
            '')
            config.files
        }

        ${lib.concatStringsSep
            "\n"
            (lib.mapAttrsToList
              (name: u:
                lib.concatMapStringsSep
                  "\n"
                  (e: ''
                    DEST="${u.home}/${e.dest}"
                    if [ -L "$DEST" ]; then
                      # Is a symlink, overwrite it
                      ln -sf "${linkSrc e}" "$DEST"
                    elif [ -f "$DEST" ]; then
                      echo "files: Error while creating symlink \"$DEST\": File in the way"
                      ERROR=1
                    else
                      ${pkgs.sudo}/bin/sudo -u "${name}" mkdir -p "$(dirname "$DEST")"
                      ${pkgs.sudo}/bin/sudo -u "${name}" ln -s "${linkSrc e}" "$DEST"
                    fi
                  '')
                  u.files
              )
              config.users.extraUsers
            )
        }

        if [ "$ERROR" != "0" ]; then
          echo "files: Please move or delete the conflicting files and activate the configuration again"
        fi

      '';
      deps = [];
    };
  };

}

