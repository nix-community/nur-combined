{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.mosh;
  # TODO: if no extraArguments are supplied, just put normal mosh-server in $PATH?
  extraArguments = map escapeShellArg cfg.extraArguments;
  mosh-server = pkgs.writeShellScriptBin "mosh-server" ''
    if [[ $1 != new ]]; then
      echo "unknown command $1" >&2
      exit 1
    fi
    shift

    exec ${cfg.package}/bin/mosh-server new ${concatStringsSep " " extraArguments} "$@"
  '';
in {
  options.services.mosh = {
    enable = mkEnableOption "mosh-server";

    package = mkOption {
      type = types.package;
      default = pkgs.mosh;
      defaultText = "pkgs.mosh";
    };

    ports = {
      from = mkOption {
        type = types.nullOr types.port;
        default = null;
        example = "30000";
      };

      to = mkOption {
        type = types.nullOr types.port;
        default = null;
        example = "40000";
      };
    };

    extraArguments = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = singleton mosh-server;
    services.mosh.extraArguments = let
      portRange = "${toString cfg.ports.from}" + optionalString (cfg.ports.to != null) ":${toString cfg.ports.to}";
    in optionals (cfg.ports.from != null) [
      "-p" portRange
    ];
    networking.firewall.allowedUDPPortRanges = mkIf (cfg.ports.from != null && cfg.ports.to != null) [ {
      inherit (cfg.ports) from to;
    } ];
    networking.firewall.allowedUDPPorts = mkIf (cfg.ports.from != null && cfg.ports.to == null) [ cfg.ports.from ];
  };
}
