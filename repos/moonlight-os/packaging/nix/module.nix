{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (utils) escapeSystemdExecArgs;
  cfg = config.services.helios;
  defaultPackage = pkgs.callPackage ./package.nix { };
  generatePorts = port: offsets: map (offset: port + offset) offsets;
in
{
  options.services.helios = {
    enable = mkEnableOption "Helios game stream host";
    package = mkOption {
      type = types.package;
      default = defaultPackage;
      description = "Helios package to run.";
    };
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start Helios with the graphical user session.";
    };
    capSysAdmin = mkOption {
      type = types.bool;
      default = false;
      description = "Grant CAP_SYS_ADMIN for DRM/KMS capture.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open Helios streaming, QUIC, and compatibility ports.";
    };
    port = mkOption {
      type = types.port;
      default = 47989;
      description = "Helios base streaming port.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.uinput.enable = true;
    services.udev.packages = [ cfg.package ];

    services.avahi = {
      enable = mkDefault true;
      publish.enable = mkDefault true;
      publish.userServices = mkDefault true;
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts =
        (generatePorts cfg.port [
          (-5)
          0
          1
          21
        ])
        ++ [ 48020 ];
      allowedUDPPorts = generatePorts cfg.port [
        9
        10
        11
        12
        13
        14
        21
      ];
    };

    security.wrappers.helios = mkIf cfg.capSysAdmin {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = getExe cfg.package;
    };

    systemd.services.helios-usb-helper = {
      description = "Helios privileged peripheral and read-only disk helper";
      wantedBy = [ "multi-user.target" ];
      wants = [ "iscsid.service" ];
      after = [
        "network.target"
        "iscsid.service"
      ];
      serviceConfig = {
        ExecStart = "${getExe cfg.package} --usb-helper";
        Restart = "on-failure";
        RestartSec = "3s";
        RuntimeDirectory = "helios";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "helios";
        StateDirectoryMode = "0700";
        Environment = "XDG_CONFIG_HOME=/var/lib/helios";
        PrivateTmp = true;
        ProtectHome = true;
        NoNewPrivileges = true;
      };
    };

    systemd.user.services.helios = {
      description = "Game stream host for Selene and Moonlight OS";
      wantedBy = mkIf cfg.autoStart [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      startLimitIntervalSec = 500;
      startLimitBurst = 5;
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        ExecStart = escapeSystemdExecArgs [
          (if cfg.capSysAdmin then "${config.security.wrapperDir}/helios" else getExe cfg.package)
        ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
