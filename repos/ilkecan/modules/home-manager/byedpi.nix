{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.byedpi;
  nixosUtils = import ../../lib/nixos-utils.nix {
    inherit lib;
    nixpkgs = pkgs.path;
  };
in
{
  meta.maintainers = with lib.maintainers; [ ilkecan ];

  options.services.byedpi = {
    enable = lib.mkEnableOption "ByeDPI, a SOCKS proxy server implementing DPI bypass methods";
    package = lib.mkPackageOption pkgs "byedpi" { };
    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [
        "--disorder"
        "1"
        "--auto=torst"
        "--tlsrec"
        "1+s"
      ];
      description = ''
        Command line arguments passed to {command}`ciadpi`. See {command}`ciadpi --help` for the available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.byedpi" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    systemd.user.services.byedpi = {
      Unit = {
        Description = "ByeDPI";
        Documentation = [ "https://github.com/hufrea/byedpi" ];
      };

      Service = {
        ExecStart = nixosUtils.escapeSystemdExecArgs ([ (lib.getExe cfg.package) ] ++ cfg.extraArgs);
        NoNewPrivileges = true;
        StandardError = "journal";
        StandardOutput = "null";
        TimeoutStopSec = "5s";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
