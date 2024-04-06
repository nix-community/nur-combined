# A library module that allows writing out configuration files even when
# programs choose to overwrite those files and destroy the symlinks.

{ lib, config, pkgs, ... }:

with lib;

let cfg = config.home.mutableFile;
in
{
  options.home.mutableFile = mkOption {
    default     = {};
    description = ''
      Writes out a file to the specified location, overwriting the file if it already
      exists.

      This is used instead of home.file when the program in question overwrites the
      symlink. This breaks the system and will prevent rebuilding until the file is
      removed.

      Either home.mutableFile."<name>".source or home.mutableFile."<name>".text must be set.
    '';

    type = with types; attrsOf (submodule {
      options = {
        enable = mkOption {
          default     = true;
          description = "Whether the file should be generated.";
          type        = bool;
        };

        source = mkOption {
          default     = null;
          description = "Path to the file to get text to write from. Mutally exclusive with home.mutableFile.<name>.text.";
          type        = nullOr path;
        };

        target = mkOption {
          default     = null;
          defaultText = "<name>";                 # Will be set to name later if left null.
          description = "The folder path relative to HOME to write the file to.";
          type        = nullOr str;
        };

        text = mkOption {
          default     = null;
          description = "The text to write. Mutally exclusive with home.mutableFile.<name>.text.";
          type        = nullOr str;
        };

        mode = mkOption {
          default     = "644";
          description = "The mode to set the file to as expected by chmod.";
          type        = str;
        };
      };
    });
  };



  config.home.activation =
    let # Finds all mutable files that are enabled.
        mutableFiles = filterAttrs (name: {enable, ...}: enable) cfg;
    in mkIf (mutableFiles != {}) (
      # Generates scripts to overwrite the target files.
      concatMapAttrs (name: value:
        let target          = if value.target != null then value.target else name;
            targetDirectory = builtins.dirOf target;
            mode            = value.mode;

            text     = if value.text != null then value.text else readFromFile value.source;
            fileName = last (path.subpath.components name);
            file     = pkgs.writeText fileName text;
        in {
          # The deleter script is used to delete the original files before the
          # "symlink" is generated.
          "home.mutableFile-${name}-deleter" = hm.dag.entryBefore ["checkLinkTargets"] ''
            $DRY_RUN_CMD rm --force ${escapeShellArg target}
          '';

          # The linker script is used to write out the specified file as a
          # "symlink."
          "home.mutableFile-${name}-linker" = hm.dag.entryAfter ["linkGeneration"] ''
            $DRY_RUN_CMD mkdir --parents ${escapeShellArg targetDirectory}
            $DRY_RUN_CMD cp ${file} ${escapeShellArg target}
            $DRY_RUN_CMD chmod ${escapeShellArg mode} ${escapeShellArg target}
          '';
        }
      ) mutableFiles
    );
}
