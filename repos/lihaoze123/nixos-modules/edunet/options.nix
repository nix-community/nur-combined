{ lib
, defaultPackage
, defaultEnvironmentFile
,
}:
{
  enable = lib.mkEnableOption "periodic campus network login";
  package = lib.mkOption {
    type = lib.types.package;
    default = defaultPackage;
    defaultText = lib.literalExpression "nur.repos.lihaoze123.edunet";
    description = "edunet CLI package to run and install.";
  };
  environmentFile = lib.mkOption {
    type = lib.types.str;
    default = defaultEnvironmentFile;
    description = "Runtime credentials file. Use a quoted string, never a Nix path or builtins.readFile.";
  };
  interval = lib.mkOption {
    type = lib.types.str;
    default = "2min";
    description = "systemd OnUnitActiveSec interval.";
  };
  startupDelay = lib.mkOption {
    type = lib.types.str;
    default = "30s";
    description = "Delay after the service manager starts (OnStartupSec).";
  };
  randomizedDelay = lib.mkOption {
    type = lib.types.str;
    default = "10s";
    description = "Maximum random delay per check.";
  };
  timeout = lib.mkOption {
    type = lib.types.ints.between 1 120;
    default = 8;
    description = "Timeout in seconds per HTTP request.";
  };
  serviceTimeout = lib.mkOption {
    type = lib.types.str;
    default = "4min";
    description = "Timeout for the entire oneshot service; increase when increasing the HTTP timeout.";
  };
}
