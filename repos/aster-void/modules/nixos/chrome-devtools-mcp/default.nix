{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.chrome-devtools-mcp;
  chrome-devtools-mcp = pkgs.callPackage ../../../packages/chrome-devtools-mcp {};
in {
  options.programs.chrome-devtools-mcp = {
    enable = mkEnableOption "chrome-devtools-mcp";

    chromePackage = mkOption {
      type = types.package;
      default = pkgs.chromium;
      description = "The chrome package to use";
    };
    overrideChromeExecutable = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Override the chrome executable path";
      example = "/nix/store/.../bin/chromium";
    };

    chromeSymlinkPath = mkOption {
      type = types.str;
      default = "/opt/google/chrome/chrome";
      description = "Path where the chrome symlink should be created";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = chrome-devtools-mcp;
      description = "The chrome-devtools-mcp package to use";
    };
  };

  config = let
    chromeExecutable =
      if cfg.overrideChromeExecutable != null
      then cfg.overrideChromeExecutable
      else lib.getExe cfg.chromePackage;
  in
    mkIf cfg.enable {
      environment.systemPackages = optional (cfg.package != null) cfg.package;
      systemd.tmpfiles.rules = [
        # Create the directory for the chrome symlink
        "d ${dirOf cfg.chromeSymlinkPath} 755 root root -"
        # Create the symlink from chrome executable to the target path
        "L+ ${cfg.chromeSymlinkPath} - - - - ${chromeExecutable}"
      ];
    };
}
