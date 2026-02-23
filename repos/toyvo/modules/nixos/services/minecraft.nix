{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.minecraft-server;

  # We don't allow eula=false anyways
  eulaFile = builtins.toFile "eula.txt" ''
    # eula.txt managed by NixOS Configuration
    eula=true
  '';

  whitelistFile = pkgs.writeText "whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (n: v: {
        name = n;
        uuid = v;
      }) cfg.whitelist
    )
  );

  cfgToString = v: if builtins.isBool v then lib.boolToString v else toString v;

  serverPropertiesFile = pkgs.writeText "server.properties" (
    ''
      # server.properties managed by NixOS configuration
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: v: "${n}=${cfgToString v}") cfg.serverProperties
    )
  );

  stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
    echo stop > ${config.systemd.sockets.minecraft-server.socketConfig.ListenFIFO}

    # Wait for the PID of the minecraft server to disappear before
    # returning, so systemd doesn't attempt to SIGKILL it.
    while kill -0 "$1" 2> /dev/null; do
      sleep 1s
    done
  '';

  # To be able to open the firewall, we need to read out port values in the
  # server properties, but fall back to the defaults when those don't exist.
  # These defaults are from https://minecraft.wiki/w/Server.properties#Java_Edition
  defaultServerPort = 25565;

  serverPort =
    if cfg.lazymc.enable then
      lib.strings.toInt (lib.lists.last (lib.strings.splitString ":" cfg.lazymc.config.public.address))
    else
      cfg.serverProperties.server-port or defaultServerPort;

  rconPort =
    if cfg.serverProperties.enable-rcon or false then
      cfg.serverProperties."rcon.port" or 25575
    else
      null;

  queryPort =
    if cfg.serverProperties.enable-query or false then
      cfg.serverProperties."query.port" or 25565
    else
      null;

in
{
  disabledModules = [
    "services/games/minecraft-server.nix"
  ];
  options = {
    services.minecraft-server = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Server. The server
          data will be loaded from and saved to
          {option}`services.minecraft-server.dataDir`.
        '';
      };

      declarative = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to use a declarative Minecraft server configuration.
          Only if set to `true`, the options
          {option}`services.minecraft-server.whitelist` and
          {option}`services.minecraft-server.serverProperties` will be
          applied.
        '';
      };

      eula = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether you agree to [Mojangs EULA](https://www.minecraft.net/eula).
          This option must be set to `true` to run Minecraft server.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/minecraft";
        description = ''
          Directory to store Minecraft database and other state/data files.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for the server.
        '';
      };

      whitelist = lib.mkOption {
        type =
          let
            minecraftUUID =
              lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
              // {
                description = "Minecraft UUID";
              };
          in
          lib.types.attrsOf minecraftUUID;
        default = { };
        description = ''
          Whitelisted players, only has an effect when
          {option}`services.minecraft-server.declarative` is
          `true` and the whitelist is enabled
          via {option}`services.minecraft-server.serverProperties` by
          setting `white-list` to `true`.
          This is a mapping from Minecraft usernames to UUIDs.
          You can use <https://mcuuid.net/> to get a
          Minecraft UUID for a username.
        '';
        example = lib.literalExpression ''
          {
            username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
          };
        '';
      };

      serverProperties = lib.mkOption {
        type =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
        default = { };
        example = lib.literalExpression ''
          {
            server-port = 43000;
            difficulty = 3;
            gamemode = 1;
            max-players = 5;
            motd = "NixOS Minecraft server!";
            white-list = true;
            enable-rcon = true;
            "rcon.password" = "hunter2";
          }
        '';
        description = ''
          Minecraft server properties forthe server.properties file. Only has
          an effect when {option}`services.minecraft-server.declarative`
          is set to `true`. See
          <https://minecraft.wiki/w/Server.properties#Java_Edition>
          for documentation on these values.
        '';
      };

      package = lib.mkPackageOption pkgs "minecraft-server" {
        example = "pkgs.minecraft-server_1_12_2";
      };

      jvmOpts = lib.mkOption {
        type = lib.types.separatedString " ";
        default = "-Xmx2048M -Xms2048M";
        # Example options from https://minecraft.wiki/w/Tutorial:Server_startup_script
        example =
          "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
          + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
          + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
        description = "JVM options for the Minecraft server.";
      };

      lazymc = {
        enable = lib.mkEnableOption "Use lazymc as a proxy to save resources";
        config = lib.mkOption {
          type = lib.types.submodule ({
            options = {
              public = {
                address = lib.mkOption {
                  type = lib.types.str;
                  default = "0.0.0.0:25565";
                  description = "Public address. IP and port users connect to. Shows sleeping status, starts server on connect, and proxies to server.";
                };
                version = lib.mkOption {
                  type = lib.types.str;
                  default = "1.20.3";
                  description = "Server version hint. Sent to clients until actual server version is known. See: https://git.io/J1Fvx";
                };
                protocol = lib.mkOption {
                  type = lib.types.int;
                  default = 765;
                  description = "Server protocol hint. Sent to clients until actual server version is known. See: https://git.io/J1Fvx";
                };
              };
              server = {
                address = lib.mkOption {
                  type = lib.types.str;
                  default = "127.0.0.1:${toString cfg.serverProperties.server-port}";
                  example = "127.0.0.1:25566";
                  description = "Server address. Internal IP and port of server started by lazymc to proxy to. Port must be different from public port.";
                };
                directory = lib.mkOption {
                  type = lib.types.str;
                  default = cfg.dataDir;
                  example = ".";
                  description = "Server directory. Defaults to current directory.";
                };
                command = lib.mkOption {
                  type = lib.types.str;
                  default = "${lib.getExe cfg.package} ${cfg.jvmOpts}";
                  example = "java -Xmx1G -Xms1G -jar server.jar --nogui";
                  description = "Command to start the server. Warning: if using a bash script read: https://git.io/JMIKH";
                };
                freeze_process = lib.mkOption {
                  type = lib.types.bool;
                  description = "Freeze the server process instead of restarting it when no players online, making it resume faster.";
                  default = true;
                };
                wake_on_start = lib.mkEnableOption "Immediately wake server when starting lazymc.";
                wake_on_crash = lib.mkEnableOption "Immediately wake server after crashes.";
                probe_on_start = lib.mkEnableOption "Probe required server details when starting lazymc, wakes server on start. Improves client compatibility. Automatically enabled if required by other config properties.";
                forge = lib.mkEnableOption "Set to true if this server runs Forge.";
                start_timeout = lib.mkOption {
                  type = lib.types.int;
                  default = 300;
                  description = "Server start timeout in seconds. Force kill server process if it takes too long.";
                };
                stop_timeout = lib.mkOption {
                  type = lib.types.int;
                  default = 150;
                  description = "Server stop timeout in seconds. Force kill server process if it takes too long.";
                };
                wake_whitelist = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "To wake server, user must be in server whitelist if enabled on server.";
                };
                block_banned_ips = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Block banned IPs as listed in banned-ips.json in server directory.";
                };
                drop_banned_ips = lib.mkEnableOption "Drop connections from banned IPs. Banned IPs won't be able to ping or request server status. On connect, clients show a 'Disconnected' message rather than the ban reason.";
                send_proxy_v2 = lib.mkEnableOption "Add HAProxy v2 header to proxied connections. See: https://git.io/J1bYb";
              };
              time = {
                sleep_after = lib.mkOption {
                  type = lib.types.int;
                  default = 60;
                  description = "Sleep after number of seconds.";
                };
                minimum_online_time = lib.mkOption {
                  type = lib.types.int;
                  default = 60;
                  description = "Minimum time in seconds to stay online when server is started.";
                };
              };
              motd = {
                sleeping = lib.mkOption {
                  type = lib.types.str;
                  default = "☠ Server is sleeping\n§2☻ Join to start it up";
                  description = "MOTD, shown in server browser.";
                };
                starting = lib.mkOption {
                  type = lib.types.str;
                  default = "§2☻ Server is starting...\n§7⌛ Please wait...";
                  description = "MOTD, shown in server browser.";
                };
                stopping = lib.mkOption {
                  type = lib.types.str;
                  default = "☠ Server going to sleep...\n⌛ Please wait...";
                  description = "MOTD, shown in server browser.";
                };
                from_server = lib.mkEnableOption "Use MOTD from Minecraft server once known.";
              };
              join = {
                methods = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [
                    "hold"
                    "kick"
                  ];
                  description = "Methods to use to occupy a client on join while the server is starting. Read about all methods and configure them below. Methods are used in order, if none is set, the client disconnects without a message.";
                };
                kick = {
                  # Kick occupation method.
                  # Instantly kicks a client with a message.
                  starting = lib.mkOption {
                    type = lib.types.str;
                    default = "Server is starting... §c♥§r\n\nThis may take some time.\n\nPlease try to reconnect in a minute.";
                    description = "Message shown when client is kicked while server is starting.";
                  };
                  stopping = lib.mkOption {
                    type = lib.types.str;
                    default = "Server is going to sleep... §7☠§r\n\nPlease try to reconnect in a minute to wake it again.";
                    description = "Message shown when client is kicked while server is stopping.";
                  };
                };
                hold = {
                  # Hold occupation method.
                  # Holds back a joining client while the server is started until it is ready.
                  # 'Connecting the server...' is shown on the client while it's held back.
                  # If the server starts fast enough, the client won't notice it was sleeping at all.
                  # This works for a limited time of 30 seconds, after which the Minecraft client times out.
                  timeout = lib.mkOption {
                    type = lib.types.int;
                    default = 25;
                    description = "Hold client for number of seconds on connect while server starts. Keep below Minecraft timeout of 30 seconds.";
                  };
                };
                forward = {
                  # Forward occupation method.
                  # Instantly forwards (proxies) the client to a different address.
                  # You may need to configure target server for it, such as allowing proxies.
                  # Consumes client, not allowing other join methods afterwards.
                  address = lib.mkOption {
                    type = lib.types.str;
                    default = "127.0.0.1:25565";
                    description = "IP and port to forward to. The target server will receive original client handshake and login request as received by lazymc.";
                  };
                  send_proxy_v2 = lib.mkEnableOption "Add HAProxy v2 header to forwarded connections. See: https://git.io/J1bYb";
                };
                lobby = {
                  # Lobby occupation method.
                  # The client joins a fake lobby server with an empty world, floating in space.
                  # A message is overlayed on screen to notify the server is starting.
                  # The client will be teleported to the real server once it is ready.
                  # This may keep the client occupied forever if no timeout is set.
                  # Consumes client, not allowing other join methods afterwards.
                  # See: https://git.io/JMIi4

                  # !!! WARNING !!!
                  # This is highly experimental, incomplete and unstable.
                  # This may break the game and crash clients.
                  # Don't enable this unless you know what you're doing.
                  #
                  # - Server must be in offline mode
                  # - Server must use Minecraft version 1.16.3 to 1.17.1 (tested with 1.17.1)
                  # - Server must use vanilla Minecraft
                  #   - May work with Forge, enable in config, depends on used mods, test before use
                  #   - Does not work with other mods, such as FTB

                  timeout = lib.mkOption {
                    type = lib.types.int;
                    default = 600;
                    description = "Maximum time in seconds in the lobby while the server starts.";
                  };
                  message = lib.mkOption {
                    type = lib.types.str;
                    default = "§2Server is starting\n§7⌛ Please wait...";
                    description = "Message banner in lobby shown to client.";
                  };
                  ready_sound = lib.mkOption {
                    type = lib.types.str;
                    default = "block.note_block.chime";
                    description = "Sound effect to play when server is ready.";
                  };
                };
              };
              lockout = {
                enabled = lib.mkEnableOption "Enable to prevent everybody from connecting through lazymc. Instantly kicks player.";
                message = lib.mkOption {
                  type = lib.types.str;
                  default = "Server is closed §7☠§r\n\nPlease try to reconnect in a minute.";
                  description = "Kick players with following message.";
                };
              };
              rcon = {
                enabled = lib.mkEnableOption "Enable sleeping server through RCON.";
                port = lib.mkOption {
                  type = lib.types.int;
                  default = cfg.serverProperties."rcon.port" or 25575;
                  example = 25575;
                  description = "Server RCON port. Must differ from public and server port.";
                };
                password = lib.mkOption {
                  type = lib.types.str;
                  default = cfg.serverProperties."rcon.password" or "";
                  description = "Server RCON password.";
                };
                randomize_password = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Whether to randomize password each start (recommended).";
                };
                send_proxy_v2 = lib.mkEnableOption "Add HAProxy v2 header to RCON connections. See: https://git.io/J1bYb";
              };
              advanced = {
                rewrite_server_properties = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Automatically update values in Minecraft server.properties file as required.";
                };
              };
              config = {
                version = lib.mkOption {
                  type = lib.types.str;
                  default = "0.2.11";
                  description = "lazymc version this configuration is for. Don't change unless you know what you're doing.";
                };
              };
            };
          });
          default = { };
          description = ''
            lazymc configuration

            You must configure your server directory and start command, see:
            - server.directory
            - server.command
          '';
        };
      };

      icon = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "The icon to use when the server is running.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.minecraft = {
      description = "Minecraft server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "minecraft";
    };
    users.groups.minecraft = { };

    systemd.sockets.minecraft-server = lib.mkIf (!cfg.lazymc.enable) {
      bindsTo = [ "minecraft-server.service" ];
      socketConfig = {
        ListenFIFO = "/run/minecraft-server.stdin";
        SocketMode = "0660";
        SocketUser = "minecraft";
        SocketGroup = "minecraft";
        RemoveOnStop = true;
        FlushPending = true;
      };
    };

    systemd.services.minecraft-server = {
      description = "Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      requires = lib.mkIf (!cfg.lazymc.enable) [ "minecraft-server.socket" ];
      after = [
        "network.target"
      ]
      ++ lib.optionals (!cfg.lazymc.enable) [ "minecraft-server.socket" ];

      serviceConfig = {
        ExecStart =
          if cfg.lazymc.enable then
            "${lib.getExe pkgs.lazymc} start"
          else
            "${cfg.package}/bin/minecraft-server ${cfg.jvmOpts}";
        ExecStop = lib.mkIf (!cfg.lazymc.enable) "${stopScript} $MAINPID";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = cfg.dataDir;

        StandardInput = lib.mkIf (!cfg.lazymc.enable) "socket";
        StandardOutput = "journal";
        StandardError = "journal";

        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      preStart = ''
        ln -sf ${eulaFile} eula.txt
      ''
      + (
        if cfg.declarative then
          ''

            if [ -e .declarative ]; then

              # Was declarative before, no need to back up anything
              ln -sf ${whitelistFile} whitelist.json
              cp -f ${serverPropertiesFile} server.properties

            else

              # Declarative for the first time, backup stateful files
              ln -sb --suffix=.stateful ${whitelistFile} whitelist.json
              cp -b --suffix=.stateful ${serverPropertiesFile} server.properties

              # server.properties must have write permissions, because every time
              # the server starts it first parses the file and then regenerates it..
              chmod +w server.properties
              echo "Autogenerated file that signifies that this server configuration is managed declaratively by NixOS" \
                > .declarative

            fi
          ''
          + lib.optionalString cfg.lazymc.enable ''
            ln -sf "${
              ((pkgs.formats.toml { }).generate "lazymc.toml" cfg.lazymc.config)
            }" "${cfg.dataDir}/lazymc.toml"
          ''
        else
          ''
            if [ -e .declarative ]; then
              rm .declarative
            fi
          ''
      )
      + lib.optionalString (cfg.icon != null) ''
        ln -sf "${cfg.icon}" "${cfg.dataDir}/server-icon.png"
      '';
    };

    networking.firewall = lib.mkIf cfg.openFirewall (
      if cfg.declarative then
        {
          allowedUDPPorts = [ serverPort ];
          allowedTCPPorts = [
            serverPort
          ]
          ++ lib.optional (queryPort != null) queryPort
          ++ lib.optional (rconPort != null) rconPort;
        }
      else
        {
          allowedUDPPorts = [ defaultServerPort ];
          allowedTCPPorts = [ defaultServerPort ];
        }
    );

    assertions = [
      {
        assertion = cfg.eula;
        message =
          "You must agree to Mojangs EULA to run minecraft-server."
          + " Read https://account.mojang.com/documents/minecraft_eula and"
          + " set `services.minecraft-server.eula` to `true` if you agree.";
      }
    ];

  };
}
