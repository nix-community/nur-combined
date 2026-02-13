{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cvm-agent;

  # State directories used by the agents:
  # - /var/lib/qcloud/stargate: sgagent state, logs, libs
  # - /var/lib/qcloud/monitor/barad: barad_agent (downloaded by sgagent at runtime)
  # - /var/lib/qcloud/monitor/python26: Python 2.6 runtime for barad_agent
  stateDir = "/var/lib/qcloud";
  stargateDir = "${stateDir}/stargate";
  monitorDir = "${stateDir}/monitor";
in
{
  options.services.cvm-agent = {
    enable = lib.mkEnableOption "Tencent Cloud CVM guest agent (Stargate + BaradAgent monitor)";

    package = lib.mkPackageOption pkgs "cvm-agent" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cvm-agent = {
      description = "Tencent Cloud CVM Guest Agent (Stargate)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      # Set up state directories with symlinks to store paths before starting
      preStart = ''
        # Ensure state directory structure exists
        mkdir -p ${stargateDir}/{bin,lib,admin,etc,logs}
        mkdir -p ${monitorDir}

        # Symlink sgagent binary and libs from the store
        ln -sfn ${cfg.package}/bin/sgagent ${stargateDir}/bin/sgagent
        for lib in ${cfg.package}/lib/*.so*; do
          ln -sfn "$lib" ${stargateDir}/lib/$(basename "$lib")
        done

        # Symlink admin scripts
        for script in ${cfg.package}/admin/*; do
          ln -sfn "$script" ${stargateDir}/admin/$(basename "$script")
        done

        # Symlink config
        ln -sfn ${cfg.package}/etc/base.conf ${stargateDir}/etc/base.conf

        # Symlink the bundled Python 2.6 for barad_agent
        # barad_agent expects it at /var/lib/qcloud/monitor/python26
        ln -sfn ${cfg.package}/python26 ${monitorDir}/python26
      '';

      serviceConfig = {
        Type = "forking";
        PIDFile = "/var/run/stargate.tencentyun.pid";
        ExecStartPre = "${pkgs.coreutils}/bin/rm -f /var/run/stargate.tencentyun.pid";
        ExecStart = "${stargateDir}/admin/start.sh";
        ExecStop = "${stargateDir}/admin/stop.sh";
        Restart = "always";
        RestartSec = 5;

        # sgagent needs write access to state dirs for:
        # - Downloading and managing barad_agent
        # - Writing logs and state files
        ReadWritePaths = [
          stateDir
          "/var/log/qcloud"
          "/var/run"
        ];

        # Hardening (relaxed from before; sgagent needs FHS-like paths)
        PrivateTmp = true;
        NoNewPrivileges = true;
      };

      environment = {
        # sgagent may need this to find its bundled libs
        LD_LIBRARY_PATH = "${stargateDir}/lib";
      };
    };

    # Create persistent directories for logs and state
    systemd.tmpfiles.rules = [
      "d /var/log/qcloud 0755 root root -"
      "d ${stateDir} 0755 root root -"
      "d ${stargateDir} 0755 root root -"
      "d ${monitorDir} 0755 root root -"
    ];
  };
}
