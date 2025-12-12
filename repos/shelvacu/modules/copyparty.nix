{
  pkgs,
  config,
  vaculib,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  copypartyModule = { name, config, ... }: {
    options = lib.attrsets.unionOfDisjoint {
      instanceName = mkOption {
        type = types.strMatching ''[a-z_-][a-z0-9_-]*'';
        default = name;
        readOnly = true;
      };
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      package = lib.mkPackageOption pkgs "copyparty-most" { };
      zeroconf = mkOption {
        type = types.bool;
        default = false;
      };
      globalConfig = mkOption {
        type = types.lines;
        default = "";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      oauthInstance = mkOption {
        type = types.str;
        default = config.instanceName;
        defaultText = lib.literalExpression "config.instanceName";
      };
      domain = mkOption {
        type = types.str;
      };
      volumes = mkOption {
        type = types.attrsOf (types.submodule volumeModule);
        default = { };
      };

      configureFileServer = mkOption {
        type = types.bool;
        default = true;
      };
      configureKanidm = mkOption {
        type = types.bool;
        default = true;
      };
    } (vaculib.mkOutOptions {
      ftpPort = 21;
      ftpsPort = 990;
      singleTCPPorts = [
        config.ftpPort
        config.ftpsPort
      ];
      singleUDPPorts = lib.optionals config.zeroconf [
        1900 # ssdp
        5353 # mDNS
      ];
      ftpPortRange = {
        from = 12000;
        to = 12999;
      };
      stateDir = "/var/lib/copyparty-${config.instanceName}";
      socketDir = "/run/copyparty-socket-${config.instanceName}";
      socketPath = "${config.socketDir}/socket.unix";
      configFile = pkgs.writeText "copyparty-${config.instanceName}.conf" ''
        [global]
        ${lib.pipe config.globalConfig [
          (lib.splitString "\n")
          (map lib.trim)
          (map (s: if s == "" then "" else "  ${s}"))
          (lib.concatStringsSep "\n")
        ]}
        ${config.extraConfig}
        ${lib.pipe config.volumes [
          builtins.attrValues
          (builtins.filter (v: v.enable))
          (lib.concatMapStringsSep "\n" (v: v.toConfigLines))
        ]}
      '';
      oauthEnabled = config.oauthInstance != null;

      mainUser = "copyparty-${config.instanceName}";
      mainGroup = config.mainUser;
      socketGroup = "copyparty-socket-${config.instanceName}";
    });
    config = {
      globalConfig = ''
        log-conn
        no-ansi
        chmod-f: ${vaculib.accessMode {
          user = {
            read = true;
            write = true;
          };
          group = {
            read = true;
            write = true;
          };
          octalLength = 3;
        }}
        chmod-d: ${vaculib.accessMode { user = "all"; group = "all"; octalLength = 3; }}
        plain-ip
        rproxy: -1
        http-no-tcp
        ah-alg: argon2
        u2sort: n
        no-robots
        ftp: ${toString config.ftpPort}
        ftps: ${toString config.ftpsPort}
        ftp-pr: ${toString config.ftpPortRange.from}-${toString config.ftpPortRange.to}
        no-clone
        xdev
        allow-flac
        allow-wav
        j: 2
        hist:${config.stateDir}
        usernames
        e2dsa
        e2ts
        daw
        i: unix:${vaculib.accessMode { user = "all"; group = "all"; octalLength = 3; }}:${config.socketGroup}:${config.socketPath}
        ${lib.optionalString config.zeroconf ''
          z
          zm-http: 80
          zm-https: 443''}
        ${lib.optionalString config.oauthEnabled ''
          idp-h-usr: X-Auth-Request-Preferred-Username
          idp-h-grp: X-Auth-Request-Group
          auth-ord: idp,pw,ipu
          idp-adm: shelvacu
          idp-login: /oauth2/start?rd={dst}
          idp-login-t: Login with id.shelvacu
          idp-logout: /oauth2/sign_out
          idp-store: 3''}
      '';
    };
  };
  # cfg = config.vacu.services.copyparty;
  volumeModule = { name, config, ... }: {
    imports = [
      (lib.mkRenamedOptionModule [ "accs" ] [ "access" ])
    ];
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      path = mkOption {
        # all printable ascii except NL, CR, tab, square brackets, and backslash
        type = types.strMatching ''/[ -Z^-~]*'';
        default = name;
        readOnly = true;
      };
      hostPath = mkOption {
        type = types.path;
        default = config.path;
      };
      bind = {
        enable = mkOption {
          type = types.bool;
          default = !isInStore config.bind.path;
          defaultText = lib.literalExpression ''!lib.path.hasStorePathPrefix config.bind.path'';
        };
        readOnly = mkOption {
          type = types.bool;
          default = false;
        };
        rbind = mkOption {
          type = types.bool;
          default = false;
        };
        path = mkOption {
          type = types.path;
          default = builtins.head (lib.splitString "\${" config.hostPath);
          defaultText = lib.literalExpression ''builtins.head (lib.splitString "\''${" config.hostPath)'';
        };
      };
      access = mkOption {
        type = types.lines;
        default = "";
      };
      flags = mkOption {
        description = ''
          Flags to set for this volume.

          ```nix
          {
            trueFlag = true;
            falseFlag = false;
            nullFlag = null;
            strFlag = "string value here";
          }
          ```

          becomes:

          ```text
          [/path]
            /host/path
            flags:
              trueFlag
              -falseFlag
              strFlag: string value here
          ```

          `null` omits the flag from the list entirely, thus inheriting from the global options. Only useful for overriding another option, otherwise just omit it.
        '';
        type = types.attrsOf (types.nullOr (types.oneOf [types.bool types.str]));
        default = { };
      };
      flagLines = mkOption {
        type = types.listOf types.str;
        internal = true;
        readOnly = true;
      };
      toConfigLines = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
      };
    };
    config.flagLines = lib.pipe config.flags [
      lib.attrsToList
      (builtins.filter (f: f.value != null))
      (map (f:
        if builtins.isString f.value then
          "${f.name}: ${f.value}"
        else if builtins.isBool f.value then
          "${lib.optionalString (!f.value) "-"}${f.name}"
        else
          throw "expected f.value to be a string or bool"
      ))
    ];
    config.toConfigLines = ''
      [${config.path}]
        ${config.hostPath}
    ''
    + (lib.optionalString (config.access != "") (
      "  accs:\n" +
      lib.pipe config.access [
        (lib.splitString "\n")
        (map lib.trim)
        (builtins.filter (s: s != ""))
        (lib.concatMapStrings (s: "    ${s}\n"))
      ]
    ))
    + (lib.optionalString (config.flagLines != [ ]) (
      "  flags:\n" +
      lib.concatMapStrings (s: "    ${s}\n") config.flagLines
    ))
    ;
  };

  getBindPaths = cfg: readOnly: lib.pipe cfg.volumes [
    builtins.attrValues
    (builtins.filter (v: v.bind.enable && (v.bind.readOnly == readOnly)))
    (map (v:
      "${systemdEscapePath v.bind.path}:${systemdEscapePath v.bind.path}:${if v.bind.rbind then "rbind" else "norbind"}"
    ))
  ];

  # copied from <nixpkgs>/lib/types.nix
  isInStore = 
    x:
    lib.path.hasStorePathPrefix (
      if builtins.isPath x then
        x
      # Discarding string context is necessary to convert the value to
      # a path and safe as the result is never used in any derivation.
      else
        /. + builtins.unsafeDiscardStringContext x
    );

  systemdEscapePath =
    lib.replaceStrings
      [
        "\\"
        ":"
        " "
        "\t"
        "\n"
        "\r"
      ]
      [
        ''\\''
        ''\072''
        ''\040''
        ''\t''
        ''\n''
        ''\r''
      ];

  mergeWhereEach =
    cond:
    f:
    lib.pipe config.vacu.copyparties [
      (builtins.attrValues)
      (builtins.filter (cfg: cfg.enable && cond cfg))
      (map f)
      lib.mkMerge
    ];

  mergeEach =
    mergeWhereEach (_: true);
in
{
  options.vacu.copyparties = mkOption {
    type = types.attrsOf (types.submodule copypartyModule);
    default = { };
  };
  config = {
    vacu.oauthProxy.instances = mergeEach (cfg:
    { ${cfg.oauthInstance} = {
        appDomain = cfg.domain;
        caddyConfig = ''
          reverse_proxy unix/${cfg.socketPath}
        '';
        requireOauth = lib.mkDefault false;
        configureKanidm = cfg.configureKanidm;
        configureCaddy = cfg.configureFileServer;
    }; }
    );

    networking.firewall = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: {
      allowedTCPPorts = cfg.singleTCPPorts;
      allowedUDPPorts = cfg.singleUDPPorts;
      allowedTCPPortRanges = [ cfg.ftpPortRange ];
    });

    users.users = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: {
      ${cfg.mainUser} = {
        isSystemUser = true;
        home = cfg.stateDir;
        group = cfg.mainGroup;
      };
    });

    users.groups = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: {
      ${cfg.mainGroup} = { };
      ${cfg.socketGroup}.members = [ cfg.mainUser "caddy" ];
    });

    systemd.tmpfiles.settings."10-whatever" = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: {
      ${cfg.socketDir}.d = {
        user = cfg.mainUser;
        group = cfg.socketGroup;
        mode = vaculib.accessModeStr {
          user = "all";
          group = "all";
        };
      };
    });

    systemd.services = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: {
      "copyparty-${cfg.instanceName}" = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "${lib.getExe cfg.package} -c ${cfg.configFile}";
          User = cfg.mainUser;
          Group = cfg.mainGroup;
          StateDirectory = "copyparty-${cfg.instanceName}";
          StateDirectoryMode = vaculib.accessModeStr { user = "all"; };

          BindPaths =
            [ cfg.socketDir ]
            ++ getBindPaths cfg false;
          BindReadOnlyPaths =
            [ ]
            ++ getBindPaths cfg true;

          UMask = vaculib.maskStr { user = "allow"; };
          # RestrictNetworkInterfaces = "";
          ProtectProc = "invisible";
          ProcSubset = "pid";
          DeviceAllow = "";
          DevicePolicy = "closed";
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          NoNewPrivileges = false;
          ProtectSystem = "strict";
          ProtectHome = true;

          PrivateTmp = true;
          PrivateDevices = true;
          PrivateIPC = true;
          PrivatePIDs = true;
          PrivateUsers = false;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = "strict";

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          PrivateMounts = true;
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "@chown"
          ];
          SystemCallArchitectures = "native";

          SocketBindAllow =
            [ "tcp:${toString cfg.ftpPortRange.from}-${toString cfg.ftpPortRange.to}" ]
            ++ (map (p: "tcp:${toString p}") cfg.singleTCPPorts)
            ++ (map (p: "udp:${toString p}") cfg.singleUDPPorts);
          SocketBindDeny = "any";
        };
      };
    });

    vacu.packages = mergeWhereEach (cfg: cfg.configureFileServer) (cfg: lib.singleton (
      pkgs.writers.writeBashBin "copyparty-${cfg.instanceName}-new-account-hash" ''
        source ${pkgs.shellvaculib.file} || exit 1
        svl_exact_args $# 1
        declare new_username="$1"
        declare new_password
        new_password="$(head -c 24 < /dev/urandom | base64)"
        declare fake_home
        fake_home="$(mktemp -d)"
        trap 'exit_code=$?; rm -rf -- "$fake_home"; exit $exit_code' EXIT
        cd -- "$fake_home"
        install --mode=u=rwx,go= -d .config/copyparty
        sudo install --mode=u=rw,go= --owner="$USER" {${cfg.stateDir}/,}.config/copyparty/ah-salt.txt
        printf "%s:%s\n" "$new_username" "$new_password" | HOME="$PWD" ${lib.getExe cfg.package} --ah-alg argon2 --ah-gen -
        echo "user: $new_username"
        echo "pass: $new_password"
      ''
    ));
  };
}
