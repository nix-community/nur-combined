{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.oracle-cloud-agent;
  pkg = cfg.package;
  agentDir = "${pkg}/lib/oracle-cloud-agent";

  # Rewrite agent.yml, replacing all /snap/oracle-cloud-agent/current paths
  # with the real Nix store paths, and fix the bastions socket path.
  agentYml = pkgs.runCommand "oracle-cloud-agent.yml" {} ''
    ${pkgs.gnused}/bin/sed \
      -e 's|/snap/oracle-cloud-agent/current|${agentDir}|g' \
      -e 's|/var/snap/oracle-cloud-agent/common/bastions|${agentDir}/plugins/bastions-config/bastions|g' \
      ${agentDir}/agent.yml > $out
  '';
in {
  _class = "nixos";

  options.services.oracle-cloud-agent = {
    enable = lib.mkEnableOption "Oracle Cloud Infrastructure agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/oracle-cloud-agent {};
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/oracle-cloud-agent {}";
      description = "The oracle-cloud-agent package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.oracle-cloud-agent = {
      description = "Oracle Cloud Infrastructure Agent";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${agentDir}/agent -agent-config ${agentYml}";
        Restart = "on-failure";
        RestartSec = "10s";

        # Log directory expected by agent.yml
        LogsDirectory = "oracle-cloud-agent";

        # Run as root — several plugins (osmh, hpc-configure, etc.) need elevated access
        User = "root";
        Group = "root";

        # Hardening — relax only what the agent actually needs
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = false; # plugins use elevated: true
      };
    };
  };
}
