# TODO: what is the right way to make sure dirs are created automatically?
# see: https://ehwiki.org/wiki/Hentai@Home
{
  lib,
  config,
  pkgs,
  vaculib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.hath;
  flags = [
    "--cache-dir=${cfg.cacheDir}"
    "--data-dir=${cfg.dataDir}"
    "--download-dir=${cfg.downloadDir}"
    "--log-dir=${cfg.logDir}"
  ]
  ++ lib.optional (!cfg.bandwidthMonitor) "--disable_bwm"
  ++ lib.optional (!cfg.logging) "--disable_logging"
  ++ lib.optional cfg.flushLogs "--flush-logs"
  ++ lib.optional (cfg.maxConnections != null) "--max-connections=${toString cfg.maxConnections}"
  ++ lib.optional (cfg.port != null) "--port=${toString cfg.port}"
  ++ lib.optional (!cfg.freeSpaceCheck) "--skip_free_space_check"
  ++ lib.optional (!cfg.ipOriginCheck) "--disable-ip-origin-check"
  ++ lib.optional (!cfg.floodControl) "--disable-flood-control"
  ++ cfg.extraArgs;
  fullCommand = lib.singleton (lib.getExe cfg.package) ++ flags;
  dirs = [
    cfg.cacheDir
    cfg.dataDir
    cfg.downloadDir
    cfg.logDir
  ];
  capabilities = [ ] ++ lib.optional cfg.allowPrivilegedPort "CAP_NET_BIND_SERVICE";
  credentialsType = types.submodule (
    { ... }:
    {
      options.clientId = mkOption { type = types.ints.unsigned; };
      options.clientKeyPath = mkOption { type = types.path; };
    }
  );
in
{
  _class = "nixos";
  options.vacu.hath = {
    enable = lib.mkEnableOption "hath";
    package = mkOption {
      type = types.package;
      default = pkgs.hentai-at-home;
      defaultText = "´pkgs.hentai-at-home`";
    };
    user = mkOption {
      type = types.passwdEntry types.str;
      default = "hath";
      readOnly = true;
    };
    group = mkOption {
      type = types.passwdEntry types.str;
      default = "hath";
      readOnly = true;
    };
    autoStart = mkOption {
      type = types.bool;
      default = false;
    };
    allowPrivilegedPort = mkOption {
      type = types.bool;
      default = cfg.port == null || cfg.port < 1024;
      defaultText = "`cfg.port == null || cfg.port < 1024`";
    };
    credentials = mkOption {
      type = types.nullOr credentialsType;
      default = null;
      description = "The credentials for this client. If null, credentials must be provided to the H@H client manually.";
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    bandwidthMonitor = mkOption {
      type = types.bool;
      default = true;
      description = "Inverse of the `--disable_bwm` option";
    };
    logging = mkOption {
      type = types.bool;
      default = true;
      description = "Inverse of the `--disable_logging` option";
    };
    flushLogs = mkOption {
      type = types.bool;
      default = false;
      description = "Equivalent to the `--flush-logs` option";
    };
    maxConnections = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Equivalent to `--max_connections=<n>`";
    };
    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = "`--port=<n>`";
    };
    freeSpaceCheck = mkOption {
      type = types.bool;
      default = true;
      description = "Inverse of `--skip_free_space_check`";
    };
    ipOriginCheck = mkOption {
      type = types.bool;
      default = true;
      description = "Inverse of `--disable-ip-origin-check`";
    };
    floodControl = mkOption {
      type = types.bool;
      default = true;
      description = "Inverse of `--disable-flood-control`";
    };

    baseDir = mkOption {
      type = types.path;
      default = "/var/lib/hath";
    };
    cacheDir = mkOption {
      type = types.path;
      default = "${cfg.baseDir}/cache";
      defaultText = lib.literalText ''/''${baseDir}/cache'';
    };
    dataDir = mkOption {
      type = types.path;
      default = "${cfg.baseDir}/data";
      defaultText = lib.literalText ''/''${baseDir}/data'';
    };
    downloadDir = mkOption {
      type = types.path;
      default = "${cfg.baseDir}/download";
      defaultText = lib.literalText ''/''${baseDir}/download'';
    };
    logDir = mkOption {
      type = types.path;
      default = "${cfg.baseDir}/log";
      defaultText = lib.literalText ''/''${baseDir}/log'';
    };

    clientLoginPath = mkOption {
      type = types.path;
      default = "${cfg.dataDir}/client_login";
      defaultText = lib.literalText ''/''${dataDir}/client_login'';
      readOnly = true;
      internal = true;
      description = "File containing the credentials, in the format {client_id}`-`{client_key}";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = { };
    systemd.services.hath = {
      wantedBy = lib.mkIf cfg.autoStart [ "multi-user.target" ];
      description = "Hentai@Home client";
      preStart = ''
        set -euo pipefail
        all_dirs=(${lib.escapeShellArgs dirs})
        for d in "''${all_dirs[@]}"; do
          containing_dir="$(dirname -- "$d")"
          mkdir -p -- "$containing_dir"
          if ! [[ -d "$d" ]]; then
            install --owner=${lib.escapeShellArg cfg.user} --group=${lib.escapeShellArg cfg.group} --mode=u=rwx,g=rx -d -- "$d"
          fi
        done
        ${lib.optionalString (cfg.credentials != null) ''
          client_id="${toString cfg.credentials.clientId}"
          client_key="$(cat ${lib.escapeShellArg cfg.credentials.clientKeyPath})"
          printf '%s-%s' "$client_id" "$client_key" > ${lib.escapeShellArg cfg.clientLoginPath}
        ''}
      '';
      script = "exec ${lib.escapeShellArgs fullCommand}";
      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        BindReadOnlyPaths = [
          "/nix/store"
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
        ];
        BindPaths = dirs;
        CapabilityBoundingSet = capabilities;
        AmbientCapabilities = capabilities;

        DeviceAllow = "";
        ProtectSystem = "strict";
        LockPersonality = true;
        # it's java, which has a JIT, so it needs write-execute memory
        # MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectControlGroups = true;
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
        SystemCallFilter = [
          "@system-service"
          "~pkey_alloc:ENOSPC"
        ];
        # this makes the default permissions u::rwx,g::r-x,o::---
        UMask = vaculib.maskStr {
          user = "allow";
          group = {
            read = "allow";
            write = "forbid";
            execute = "allow";
          };
        };
      };
    };
  };
}
