{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.rangefs;
  rangefsPkg = pkgs.callPackage ../../pkgs/top-level/rangefs {};
in
{
  ## Interface

  options.programs.rangefs = let
    fileSystemOpts = let
      configOpts = {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Name of mapped file for this range";
          };
          offset = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Offset in the source file as start of range in bytes";
          };
          size = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Size of the range in bytes";
          };
          uid = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Uid of the mapped file";
          };
          gid = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Gid of the mapped file";
          };
        };
      };
    in {
      options = {
        source = mkOption {
          type = types.str;
          description = "Source file to map ranges from";
        };
        config = mkOption {
          type = types.nonEmptyListOf (types.submodule configOpts);
          default = [];
          description = "Config for each mapped range";
        };
        timeout = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Timeout for metadata and cache in seconds";
        };
        file = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Overwrite the source file";
        };
        stdout = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Redirect stdout to file";
        };
        stderr = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Redirect stderr to file";
        };
        extraOptions = mkOption {
          type = types.listOf types.str;
          default = [];
          example = [ "nofail" ];
          description = "Extra options passed to fileSystems.<name>.options";
        };
      };
    };
  in {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable rangefs";
    };

    package = mkOption {
      type = types.package;
      default = rangefsPkg;
      defaultText = literalExpression "nur-dcsunset.packages.rangefs";
      description = "The rangefs package to use (e.g. package from nur)";
    };

    fileSystems = mkOption {
      type = types.attrsOf (types.submodule fileSystemOpts);
      default = {};
      example = {
        "/mount_point" = {
          file = "/path/to/file";
          config = [ {} ];
        };
      };
    };
  };


  ## Implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    fileSystems = builtins.mapAttrs (_: fs: let
      configList = [ "file" "timeout" "stdout" "stderr" ];
      # convert to key value str if value not null
      keyValueStr = sep: k: v:
        if v != null then "${k}${sep}${toString v}" else null;
    in {
      device = fs.source;
      fsType = "fuse.rangefs";
      options = let
        optionList = [ "name" "offset" "size" "uid" "gid" ];
      in [
        (builtins.concatStringsSep "::" (
          [ "config" ] ++
          (map (c: builtins.concatStringsSep ":" (
            filter
              (x: x != null)
              (map
                (k: keyValueStr "=" k c."${k}")
                optionList)
          )) fs.config)
        ))
      ] ++(
        filter
          (x: x != null)
          (map
            (k: keyValueStr "::" k fs."${k}")
            configList)
      ) ++ fs.extraOptions;
    }) cfg.fileSystems;
  };
}
