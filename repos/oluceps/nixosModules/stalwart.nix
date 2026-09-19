{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.stalwart;

  # In Stalwart 0.16, all configuration except the underlying datastore is managed
  # inside the database via the JMAP API or stalwart-cli.
  # We generate a minimal config.json just for the RocksDB backend.
  configFile = pkgs.writeText "stalwart-config.json" (
    builtins.toJSON {
      "@type" = "RocksDb";
      path = "${cfg.dataDir}/db";
    }
  );
in
{
  # Disable the built-in module from nixpkgs which is pinned to 0.15
  disabledModules = [ "services/mail/stalwart.nix" ];

  options.services.stalwart = {
    enable = mkEnableOption "Stalwart Mail Server (0.16+)";

    package = mkOption {
      type = types.package;
      default = pkgs.stalwart_0_16;
      defaultText = literalExpression "pkgs.stalwart_0_16";
      description = "The Stalwart package to use. Must be 0.16+.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/stalwart";
      description = "The directory where Stalwart stores its data and database.";
    };

    # The following dummy options are provided so that your existing 0.15 configuration
    # doesn't throw evaluation errors. They are ignored by the 0.16 service.
    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        IGNORED IN 0.16. 
        All settings are now managed via stalwart-cli or WebUI.
      '';
    };

    stateVersion = mkOption {
      type = types.str;
      default = "1";
      description = "IGNORED IN 0.16.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.stalwart-cli
    ];

    users.users.stalwart = {
      isSystemUser = true;
      group = "stalwart";
      home = cfg.dataDir;
      createHome = true;
    };
    users.groups.stalwart = { };

    systemd.services.stalwart = {
      description = "Stalwart Mail Server (0.16+)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = "stalwart";
        Group = "stalwart";
        WorkingDirectory = cfg.dataDir;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        StateDirectory = "stalwart";
        ExecStart = "${cfg.package}/bin/stalwart --config ${configFile}";
        Restart = "always";
        LimitNOFILE = 65536;
      };
    };
  };
}
