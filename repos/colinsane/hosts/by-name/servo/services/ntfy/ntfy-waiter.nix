# service which adapts ntfy-sh into something suitable specifically for the Pinephone's
# wake-on-lan (WoL) feature.
# notably, it provides a mechanism by which the caller can be confident of an interval in which
# zero traffic will occur on the TCP connection, thus allowing it to enter sleep w/o fear of hitting
# race conditions in the Pinephone WoL feature.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.ntfy-waiter;
  portLow = 5550;
  portHigh = 5559;
  portRange = lib.range portLow portHigh;
  numPorts = portHigh - portLow + 1;
  mkService = port: let
    silence = port - portLow;
    flags = lib.optional cfg.verbose "--verbose";
    cli = [
      (lib.getExe cfg.package)
      "--port"
      "${builtins.toString port}"
      "--silence"
      "${builtins.toString silence}"
    ] ++ flags;
  in {
    "ntfy-waiter-${builtins.toString silence}" = {
      # TODO: run not as root (e.g. as ntfy-sh)
      description = "wait for notification, with ${builtins.toString silence} seconds of guaranteed silence";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
        ExecStart = lib.concatStringsSep " " cli;
      };
      after = [ "network.target" ];
      wantedBy = [ "ntfy-sh.service" ];
    };
  };
in
{
  options = with lib; {
    sane.ntfy-waiter.enable = mkOption {
      type = types.bool;
      default = config.services.ntfy-sh.enable;
      defaultText = lib.literalExpression "config.services.ntfy-sh.enable";
    };
    sane.ntfy-waiter.verbose = mkOption {
      type = types.bool;
      default = true;
    };
    sane.ntfy-waiter.package = mkOption {
      type = types.package;
      default = pkgs.static-nix-shell.mkPython3 {
        pname = "ntfy-waiter";
        srcRoot = ./.;
        pkgs = [ "ntfy-sh" ];
      };
      description = ''
        exposed to provide an attr-path by which one may build the package for manual testing.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sane.ports.ports = lib.mkMerge (lib.forEach portRange (port: {
      "${builtins.toString port}" = {
        protocol = [ "tcp" ];
        visibleTo.doof = true;
        visibleTo.lan = true;
        description = "colin-notification-waiter-${builtins.toString (port - portLow + 1)}-of-${builtins.toString numPorts}";
      };
    }));
    systemd.services = lib.mkMerge (builtins.map mkService portRange);
  };
}
