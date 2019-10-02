{ config, lib, ... }: with lib; let
  cfg = config.home.nix;
  nixPathDirs = filterAttrs (_: v: v.type == "path") config.home.nix.nixPath;
  nixPaths = filterAttrs (_: v: v.type != "path") config.home.nix.nixPath;
  nixPaths' = mapAttrsToList (k: v: "${k}=${v}") nixPaths;
  nixPath = [
    config.home.nix.nixPathDirectory
  ] ++ nixPaths';
  sessionVariables = {
    NIX_PATH = concatStringsSep ":" nixPath;
  };
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
            type = types.str;
            default = name;
          };
          type = mkOption {
            type = types.enum [ "path" "url" ];
            default = if hasPrefix "/" config.path then "path" else "url";
          };
          path = mkOption {
            type = types.str;
          };
        };
      });
      fudge = types.coercedTo types.str (path: {
        inherit path;
      }) pathType;
    in mkOption {
      type = types.attrsOf fudge;
      default = { };
    };
  };
  config.home = mkIf cfg.enable {
    inherit sessionVariables;
    # TODO: bash, zsh, systemd.user?
    # TODO: also set nixos settings?
    symlink = mapAttrs' (k: v: nameValuePair ".config/nix/path/${k}" {
      target = v.path;
      create = false;
    }) nixPathDirs;
  };
}
