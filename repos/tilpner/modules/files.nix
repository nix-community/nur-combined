{ config, lib, pkgs, ... }:
with lib;

let
  inherit (pkgs) stdenv writeScript writeText coreutils;

  attrsToNamedList = mapAttrsToList (k: v: v // { name = k; });
  concatMapAttrsStringsSep = sep: f: attrs: concatStringsSep sep (mapAttrsToList f attrs);
  setEnvArgs = args: concatMapAttrsStringsSep "\n" (k: v: "${toUpper k}=${escapeShellArg v}") args;
  callWithEnvArgs = fName: args: "${setEnvArgs args}\n${fName}\n";

  cleanDots = replaceStrings ["."] [""];

  head = ''
    make_permissions() {
      if [ -n "$USER" ]; then
        if [ -n "$GROUP" ]; then
          chown "$USER:$GROUP" "$TARGET"
        else
          chown "$USER" "$TARGET"
        fi
      else
        chown --reference="$(dirname $TARGET)" "$TARGET"
      fi

      if [ -n "$MODE" ]; then
        # GNU chmod doesn't touch setuid/setgid with 0000
        chmod 00000 "$TARGET"
        chmod "$MODE" "$TARGET"
      fi
    }

    make_directory() {
      echo "$TARGET"
      if [ -n "$SOURCE" ]; then
        ln -v --symbolic --no-target-directory --force "$SOURCE" "$TARGET"
      else
        mkdir -p "$TARGET"
      fi
      make_permissions
    }

    make_file() {
      echo "$TARGET"
      mkdir -p "$(dirname "$TARGET")"
      if [ -n "$SYMLINK" ]; then
        ln --symbolic --no-target-directory --force "$SOURCE" "$TARGET"
      else
        if ! [ -f "$SOURCE" ]; then
          echo "$SOURCE is not a file, refusing to copy"
          return 1
        fi
        cp --no-target-directory --remove-destination "$SOURCE" "$TARGET"
        make_permissions
      fi
    }
  '';

  updateSingleDirectory =
    root: dir: callWithEnvArgs "make_directory" {
      target = root + ("/" + dir.name);
      inherit (dir) source mode user group;
    };

  updateSingleFile =
    root: file: callWithEnvArgs "make_file" {
      target = root + ("/" + file.name);
      inherit (file) source symlink mode user group;
    };

  updateFileSet =
    { name, root, directories, files, ... }:
    let activeFiles = filterAttrs (k: v: v.enable) files;
        activeDirs  = filterAttrs (k: v: v.enable) directories;
    in writeScript "files-${name}" ''
      #!${stdenv.shell}
      set -e

      PATH=${coreutils}/bin

      ${head}

      echo ${escapeShellArg "updating files/${name}"}

      ${concatMapStringsSep "\n" (updateSingleDirectory root) (attrsToNamedList activeDirs)}
      ${concatMapStringsSep "\n" (updateSingleFile root) (attrsToNamedList activeFiles)}
    '';

  updateFiles = cfg: concatMapStringsSep "\n" updateFileSet (attrsToNamedList cfg);

in {
  options.environment.files = mkOption {
    description = "Unsafe file management with the API of environment.etc, but usable everywhere";
    default = {};
    type = with types; attrsOf (submodule {
      options = {
        #careful = mkOption {
        #  type = bool;
        #  default = true;
        #};

        root = mkOption {
          type = str;
          default = "";
        };

        directories = mkOption {
          default = {};
          type = attrsOf (submodule
             ({ name, config, ... }: {
              options = {
                enable = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    Whether this file should be generated. This
                    option allows specific files to be disabled.
                  '';
                };

                source = mkOption {
                  default = null;
                  type = nullOr path;
                  description = "Path of the source file.";
                };

                mode = mkOption {
                  default = null;
                  type = nullOr str;
                  example = "0600";
                };

                uid = mkOption {
                  default = null;
                  type = nullOr int;
                  description = "UID of created file.";
                };

                gid = mkOption {
                  default = null;
                  type = nullOr int;
                  description = "GID of created file.";
                };

                user = mkOption {
                  default = null;
                  type = nullOr str;
                  description = ''
                    User name of created file.
                    Changing this option takes precedence over <literal>uid</literal>.
                  '';
                };

                group = mkOption {
                  default = null;
                  type = nullOr str;
                  description = ''
                    Group name of created file.
                    Changing this option takes precedence over <literal>gid</literal>.
                  '';
                };
              };

              config = { 
                user = mkIf (config.uid != null)
                  (mkDefault "+${toString config.uid}");
                group = mkIf (config.gid != null)
                  (mkDefault "+${toString config.gid}");
              };
            })
          );
        };

        files = mkOption {
          default = {};
          type = attrsOf (submodule
            ({ name, config, ... }: {
              options = {
                enable = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    Whether this file should be generated. This
                    option allows specific files to be disabled.
                  '';
                };

                text = mkOption {
                  default = null;
                  type = nullOr lines;
                  description = "Text of the file.";
                };

                source = mkOption {
                  type = path;
                  description = "Path of the source file.";
                };

                symlink = mkOption {
                  internal = true;
                  type = bool;
                  default = true;
                };

                mode = mkOption {
                  default = null;
                  type = nullOr str;
                  example = "0600";
                };

                uid = mkOption {
                  default = null;
                  type = nullOr int;
                  description = "UID of created file.";
                };

                gid = mkOption {
                  default = null;
                  type = nullOr int;
                  description = "GID of created file.";
                };

                user = mkOption {
                  default = null;
                  type = nullOr str;
                  description = ''
                    User name of created file.
                    Changing this option takes precedence over <literal>uid</literal>.
                  '';
                };

                group = mkOption {
                  default = null;
                  type = nullOr str;
                  description = ''
                    Group name of created file.
                    Changing this option takes precedence over <literal>gid</literal>.
                  '';
                };
              };

              config = { 
                user = mkIf (config.uid != null)
                  (mkDefault "+${toString config.uid}");
                group = mkIf (config.gid != null)
                  (mkDefault "+${toString config.gid}");

                # internal option, so okay to set completely
                symlink = with config; mode == null && user == null && group == null;
                # writeText doesn't allow names to contain too many dots
                source = mkIf (config.text != null) 
                  (mkDefault (writeText (cleanDots (baseNameOf name)) config.text));
              };
            })
          );
        };
      };
    });
  };

  config = {
    system.activationScripts = {
      files = {
        deps = [ "stdio" "users" "groups" ];
        text = ''
          echo "setting up files..."
          ${updateFiles config.environment.files}
        '';
      };
    };
  };
}
