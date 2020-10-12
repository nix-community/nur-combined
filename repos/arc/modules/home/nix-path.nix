{ config, lib, ... }: with lib; let
  cfg = config.home.nix;
  nixPathDirs = filterAttrs (_: v: v.type == "path") config.home.nix.nixPath;
  nixPaths = filterAttrs (_: v: v.type != "path") config.home.nix.nixPath;
  nixPaths' = mapAttrsToList (_: v: v.repr) nixPaths;
  nixPath = [
    config.home.nix.nixPathDirectory
  ] ++ nixPaths' ++ workaround;
  sessionVariables = {
    NIX_PATH = concatStringsSep ":" nixPath;
  };
  # nix 2.0 CLI adds magic default attrs for NIX_PATH entries, but doesn't support populating it from prefixless paths so fix that
  # (it will actually still load them from the prefixless path, but there need to be explicit entries so it knows the keys)
  # alternatively: "${k}=${config.home.nix.nixPathDirectory}/${k}"
  workaround = mapAttrsToList (k: _: "${k}=/xxx") nixPathDirs;
in {
  options.home.nix = {
    enable = mkEnableOption "nix configuration";
    nixPathDirectory = mkOption {
      type = types.path;
      default = config.xdg.configHome + "/nix/path";
    };
    nixPath = let
      pathType = types.submodule ({ name, config, ... }: {
        options = {
          name = mkOption {
            type = types.nullOr types.str;
            default = name;
          };
          type = mkOption {
            type = types.enum [ "path" "url" "explicit" ];
            default = if hasPrefix "/" config.path then "path" else "url";
          };
          path = mkOption {
            type = types.str;
          };
          repr = mkOption {
            type = types.str;
            default = if config.name == null
              then config.path
              else "${config.name}=${config.path}";
          };
        };
      });
      fudge = types.coercedTo types.str (path: {
        inherit path; # TODO: detect path vs url
      }) pathType;
    in mkOption {
      type = types.attrsOf fudge;
      default = { };
    };
  };
  config = mkIf cfg.enable {
    home = {
      nix.nixPath = {
        default = mkOptionDefault {
          type = "explicit";
          path = ".";
        };
        release = mkOptionDefault {
          type = "explicit";
          path = "./release.nix";
        };
      };
      inherit sessionVariables;
    };
    # TODO: bash, zsh, systemd.user?
    # TODO: also set nixos settings?
    xdg.configFile = mapAttrs' (k: v: nameValuePair "nix/path/${k}" {
      source = config.lib.file.mkOutOfStoreSymlink v.path;
    }) nixPathDirs;
  };
}
