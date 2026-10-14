moduleArgs @ {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.magpie;
  serviceLib = import ../../internal/system-service {inherit lib pkgs;};
  magpie = import ../../modules/magpie (moduleArgs // {inherit serviceLib;});
in {
  options.services.magpie =
    magpie.options
    // {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "magpie package. Null runs `/Applications/magpie.app`, as the `magpie-app` Homebrew cask installs it.";
      };

      logFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/Users/alice/Library/Logs/magpie.log";
        description = "File the gateway's output is appended to.";
      };
    };

  config = lib.mkIf cfg.enable (serviceLib.mkDarwin (magpie.mkService {
    executable =
      if cfg.package == null
      then "/Applications/magpie.app/Contents/MacOS/magpie"
      else lib.getExe cfg.package;
    packages = lib.optional (cfg.package != null) cfg.package;

    darwin = {
      agent = true;
      standardOutPath = cfg.logFile;
      standardErrorPath = cfg.logFile;
    };
  }));
}
