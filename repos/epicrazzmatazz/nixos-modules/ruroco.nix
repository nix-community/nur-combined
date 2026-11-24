{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ruroco;
  settingsFormat = pkgs.formats.toml {};
in
  {
    # TODO generic services.ruroco.settings option to pass raw toml in, conforming to convention specified in nixos manual
    # settings = {
    #  type = settingsFormat.type;
    #};
    options = {
      services.ruroco = {
        # options TODO: pass raw options to toml file
        enable = lib.mkEnableOption "ruroco server";
        autostart = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to automatically start `ruroco-commander.service`.
            `ruroco.socket` is always started, depending on `sockets.target` and `ruroco-server.service` is socket-activated.
          '';
        };
        stateDir = lib.mkOption{
          type = lib.types.externalPath;
          default = /var/lib/ruroco;
          description = ''
            In the state directory, the server searches for .key files, maintains the replay protection blocklist, and puts a socket TODO for what.
            Put your symmetric keys made with `ruroco-client gen` here, and make sure they are `chmod`ed to 400 and owned by the ruroco user and group.
          '';
        };
        # TODO make required
        ips = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Public IP address of your server where this service runs on
          '';
        };
        useUnixSocketIPC = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to open a unix domain socket for ruroco commander-server interprocess communication.
          '';
        };
        IPAddressIPC = lib.mkOption {
          type = lib.types.str;
          default = "[::]:8080";
          description = ''
            IP address to use for ruroco commander-server interprocess communication.
            Does nothing if `useUnixSocketIPC` is `true`.
            You may want to change the port number in case you have other processes listening on localhost.
          '';
        };
        user = lib.mkOption {
          default = "ruroco";
          type = lib.types.str;
          description = ''
            User to run ruroco daemons as.
          '';
        };
        group = lib.mkOption {
          default = "ruroco";
          type = lib.types.str;
          description = ''
            Group to run ruroco daemons as.
          '';
        };
        commands = lib.mkOption {
          default = {};
          type = lib.types.attrsOf lib.types.str;
          description = ''
            Command definitions for `ruroco-commander` as they would appear in the `config.toml`.
          '';
          # TODO examples
        };
      };
    };

    ###### implementation

    config =
    let
			# toml config is a derivation, it is not in the stateDir
      configFile = pkgs.writers.writeTOML "ruroco-config.toml" {
        ips = cfg.ips;
        # TODO this messes up the generated config
        address = lib.mkIf (!cfg.useUnixSocketIPC) cfg.IPAddressIPC;
        config_dir = cfg.stateDir;
        socket_user = cfg.user;
        socket_group = cfg.group;
        # ntp key seems to be not implemented in source code
        # [commands] section
        commands = cfg.commands;
      };
    in
      lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.ruroco ];

        # create stateDir, default /var/lib/ruroco
        systemd.tmpfiles.rules = [
          "d '${cfg.stateDir}' 770 ${cfg.user} ${cfg.group} - -"
        ];

        users = {
          groups.${cfg.group} = {};
          users.${cfg.user} = {
            isSystemUser = true;
            group = cfg.group;
            home = "/var/lib/ruroco";
            createHome = true;
          };
        };

        # commander executes predefined commands when instructed by server
				# this unit is copied from upstream
        systemd.services."ruroco-commander" = {
          path = [ pkgs.bashNonInteractive ];
          wantedBy = if cfg.autostart == true then [ "multi-user.target" ] else [];
          unitConfig = {
          Description = "ruroco commander service";
          Requires = "network-online.target";
          After = "network-online.target";
          };
          serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.ruroco}/bin/ruroco-commander --config ${configFile}";
          Restart = "always";
          DeviceAllow = "";
          LockPersonality = true;
          NoNewPrivileges = true;
          ProtectClock = true;
          ProtectHostname = true;
          RestrictAddressFamilies = "";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";
          SystemCallFilter = "~@clock ~@cpu-emulation ~@debug ~@keyring ~@memlock ~@module ~@obsolete ~@raw-io ~@reboot ~@resources ~@setuid";
          UMask = "0077";
          };
        };

        # the server processes incoming knock packets
				# this unit is copied from upstream
        systemd.services."ruroco-server" = {
          wantedBy = if cfg.autostart == true then [ "multi-user.target" ] else [];
          unitConfig = {
            Description = "ruroco service";
            Requires = "network-online.target ruroco.socket ruroco-commander.service";
            After = "network-online.target ruroco.socket ruroco-commander.service";
          };
          serviceConfig = {
            Type = "simple";
            # separate the config.toml from the stateDir
            ExecStart = "${pkgs.ruroco}/bin/ruroco-server --config ${configFile}";
            Restart = "always";
            User = cfg.user;
            Group = cfg.group;
            RemoveIPC = true;
            CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
            DeviceAllow = "";
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "noaccess";
            ProtectSystem = "strict";
            ReadWritePaths = cfg.stateDir;
            RestrictAddressFamilies = "AF_UNIX";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = "@system-service ~@chown ~@clock ~@cpu-emulation ~@debug ~@keyring ~@memlock ~@module ~@mount ~@obsolete ~@privileged ~@raw-io ~@reboot ~@resources ~@setuid";
            UMask = "0077";
          };
        };

        # IPC for commander and server
        systemd.sockets.ruroco = {
          partOf = [ "ruroco-server.service" ];
          wantedBy = [ "sockets.target" ];
          unitConfig = {
            Description = "ruroco socket";
          };
          socketConfig = {
            # This listens for both IPv4 and IPv6 if IPV6_V6ONLY is disabled, which is the default on linux,
            # see https://man7.org/linux/man-pages/man7/ipv6.7.html => /proc/sys/net/ipv6/bindv6only == 0
            ListenDatagram = "[::]:80";
            Service = "ruroco-server.service";
          };
        };
      };
  }
