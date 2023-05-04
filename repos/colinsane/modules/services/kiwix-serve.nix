{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.services.kiwix-serve;
in
{
  options = {
    sane.services.kiwix-serve = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.kiwix-tools;
        defaultText = literalExpression "pkgs.kiwix-tools";
        description = lib.mdDoc ''
          The package that provides `bin/kiwix-serve`.
        '';
      };
      port = mkOption {
        type = types.port;
        default = 80;
        description = lib.mdDoc "Port number to listen on.";
      };
      listenAddress = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = lib.mdDoc ''
          IP address to listen on. Listens on all available addresses if unspecified.
        '';
      };
      zimPaths = mkOption {
        type = types.nonEmptyListOf (types.either types.str types.path);
        description = lib.mdDoc "ZIM file path(s)";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.kiwix-serve = {
      description = "Deliver ZIM file(s) articles via HTTP";
      serviceConfig = let
        maybeListenAddress = lib.optionals (cfg.listenAddress != null) ["-l" cfg.listenAddress];
        args = maybeListenAddress ++ ["-p" cfg.port] ++ cfg.zimPaths;
      in {
        ExecStart = "${cfg.package}/bin/kiwix-serve ${lib.escapeShellArgs args}";
        Type = "simple";
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
