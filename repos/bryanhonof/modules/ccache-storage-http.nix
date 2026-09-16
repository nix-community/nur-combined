# Run ccache's HTTP(S) remote storage helper outside the Nix build sandbox and
# hand its socket to the builds that ask for it.
#
# Normally ccache spawns a storage helper itself and talks to it over a Unix
# socket. That cannot work inside a Nix build sandbox, because the helper would
# be spawned *in* the sandbox, where there is no network. ccache's `crsh:` URL
# scheme exists for this case: it connects to an already-running helper and
# never spawns one. So we run the helper as a system service and bind-mount its
# socket into the sandbox, via `programs.nix-required-mounts`, for derivations
# carrying the `ccache-use-storage-helper` system feature.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ccache-storage-http;

  defaultUser = "ccache-storage-http";

  socketDir = builtins.dirOf cfg.socketPath;
  runtimeDirMatch = builtins.match "/run/([^/]+)" socketDir;
  runtimeDirName = if runtimeDirMatch == null then null else builtins.head runtimeDirMatch;

  # netrcFile is just the `netrc-file` attribute given a dedicated option,
  # because it also needs the file reachable through the service's sandboxing.
  attributes =
    cfg.attributes // lib.optionalAttrs (cfg.netrcFile != null) { "netrc-file" = cfg.netrcFile; };

  # A helper receives the `@key=value` attributes of ccache's remote_storage
  # setting as a numbered list of environment variables.
  attrPairs = lib.concatMap (
    { name, value }:
    map (v: {
      inherit name;
      value = v;
    }) (lib.toList value)
  ) (lib.attrsToList attributes);

  attrEnv = lib.mergeAttrsList (
    lib.imap0 (i: attr: {
      "CRSH_ATTR_KEY_${toString i}" = attr.name;
      "CRSH_ATTR_VALUE_${toString i}" = attr.value;
    }) attrPairs
  );

  # Anything named `*-file` -- `netrc-file`, `bearer-token-file` -- is a path the
  # helper reads at runtime, and typically one the sandboxing below would hide.
  attrFiles = lib.concatMap (
    { name, value }: lib.optional (lib.hasSuffix "-file" name) value
  ) attrPairs;

  # The helper writes its diagnostics to the file named by CRSH_LOGFILE and
  # nowhere else, so to get them into the journal we point it at our own stderr.
  # /dev/stderr cannot be opened directly: systemd connects stderr to a journal
  # *socket*, and open(2) on a socket via /proc/self/fd fails with ENXIO. A pipe
  # can be opened, so interpose one and copy it back to the real stderr.
  journalStartScript = pkgs.writeShellScript "ccache-storage-http-start" ''
    exec 2> >(exec ${pkgs.coreutils}/bin/cat >&2)
    exec ${lib.getExe' cfg.package "ccache-storage-http"}
  '';

  # The helper always creates its socket under umask 077 (it sets that itself,
  # so systemd's UMask= cannot influence it), leaving it accessible only to the
  # service user. Widen it so the Nix build users can connect. The unit is
  # Type=simple by default, so ExecStartPost may run before the socket exists.
  openSocketScript = pkgs.writeShellApplication {
    name = "ccache-storage-http-open-socket";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      until [ -S "${cfg.socketPath}" ]; do
        sleep 0.1
      done
      chmod ${cfg.socketMode} "${cfg.socketPath}"
    '';
  };
in
{
  options.services.ccache-storage-http = {
    enable = lib.mkEnableOption ''
      the ccache HTTP(S) remote storage helper, shared with Nix build sandboxes
      over a Unix socket
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ccache-storage-http-go or (pkgs.callPackage ../pkgs/ccache-storage-http-go { });
      defaultText = lib.literalExpression "pkgs.ccache-storage-http-go";
      description = "The ccache-storage-http-go package to run.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      example = "https://ccache.example.com";
      description = ''
        URL of the remote storage server. Only this service connects to it;
        builds reach it through {option}`services.ccache-storage-http.socketPath`.
      '';
    };

    attributes = lib.mkOption {
      type = with lib.types; attrsOf (either str (listOf str));
      default = { };
      example = lib.literalExpression ''
        {
          layout = "bazel";
          "bearer-token-file" = "/run/secrets/ccache-token";
          header = [ "X-Team=compilers" ];
        }
      '';
      description = ''
        Helper attributes, given without the leading `@` -- the same set that
        would otherwise follow the URL in ccache's `remote_storage` setting. A
        list value repeats the key, which `header` expects.

        Because the helper runs outside the sandbox, secrets referenced here
        stay out of the store and out of builds. Prefer `bearer-token-file` over
        `bearer-token`: the helper re-reads the file per request, so the token
        can be rotated without a restart.

        Every attribute whose name ends in `-file` is bind-mounted into the
        service, so it may sit somewhere the service's own sandboxing would
        otherwise hide, such as under a home directory. Such a file has to be
        readable by {option}`services.ccache-storage-http.user`, and is best
        kept out of the Nix store, which is world-readable.
      '';
    };

    netrcFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/secrets/ccache-netrc";
      description = ''
        Absolute path to a netrc file the helper authenticates with, passed on
        as the `netrc-file` attribute of
        {option}`services.ccache-storage-http.attributes` and bind-mounted like
        the other `*-file` attributes. The helper matches the entry on the URL's
        host name with the port left off, so a `machine ccache.example.com`
        line, and sends its `login` and `password` as HTTP Basic credentials.

        Unlike a bearer token file, this is read once at startup: changing it
        takes a restart of the service.
      '';
    };

    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/ccache-storage-http/socket";
      description = ''
        Unix socket the helper listens on, and the path bind-mounted into the
        sandbox. It has to be a file directly under {file}`/run/<name>/`, which
        is managed as the service's systemd runtime directory.
      '';
    };

    socketMode = lib.mkOption {
      type = lib.types.str;
      default = "0770";
      description = ''
        Permissions to set on the socket once the helper has bound it. Connecting
        requires write permission, so every user in
        {option}`services.ccache-storage-http.group` that can reach the socket can
        read and write the remote cache -- the IPC protocol has no authentication
        of its own.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = ''
        User to run the helper as. Created only when left at its default; any
        other user has to be declared elsewhere.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = config.programs.ccache.group;
      defaultText = lib.literalExpression "config.programs.ccache.group";
      description = ''
        Group owning the socket. Defaults to the group of the ccache directory,
        which is the Nix build users' group, so that sandboxed builds can connect.
      '';
    };

    journalLog = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Route the helper's diagnostic log to the journal. The log is not
        redacted and may contain bearer tokens and other credentials, so it
        inherits whatever access the journal grants.

        On by default because the helper is otherwise silent even about startup
        failures, since it reports errors only through this log.
      '';
    };

    systemFeature = lib.mkOption {
      type = lib.types.str;
      default = "ccache-use-storage-helper";
      description = ''
        System feature that a derivation requests, through
        `requiredSystemFeatures`, to get the ccache directory and the helper
        socket mounted into its sandbox.

        Only this machine advertises the feature, and the mounting hook runs
        only for builds executed here, so every machine that is to build such a
        derivation -- remote builders included -- needs this service enabled too.
      '';
    };

    configureCcache = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Point ccache at this helper: the ccache compiler wrapper exports
        `CCACHE_REMOTE_STORAGE`, and every package in
        {option}`programs.ccache.packageNames` requests
        {option}`services.ccache-storage-http.systemFeature`, so those packages
        build against the remote cache with no further changes.

        Derivations that use {var}`ccacheStdenv` directly rather than through
        {option}`programs.ccache.packageNames` still pick up the wrapper's
        `CCACHE_REMOTE_STORAGE`, but have to request the system feature
        themselves, or their sandbox will not have the socket in it.

        Turn this off to wire up ccache by hand, using
        {option}`services.ccache-storage-http.remoteStorage`.
      '';
    };

    remoteStorage = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "crsh:${cfg.socketPath}";
      description = ''
        Value for ccache's `remote_storage` setting (`CCACHE_REMOTE_STORAGE`)
        that connects to this helper. Useful for derivations that configure
        ccache themselves.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.programs.ccache.enable;
        message = ''
          services.ccache-storage-http requires programs.ccache.enable, which
          provides the local cache directory (programs.ccache.cacheDir) that is
          mounted into the sandbox alongside the helper socket.
        '';
      }
      {
        assertion = runtimeDirName != null;
        message = ''
          services.ccache-storage-http.socketPath must be a file directly under
          /run/<name>/, which is what systemd's RuntimeDirectory= manages and
          one of the few places still writable under ProtectSystem=strict, but
          it is ${cfg.socketPath}.
        '';
      }
      {
        assertion = lib.versionAtLeast pkgs.ccache.version "4.13";
        message = ''
          services.ccache-storage-http needs ccache 4.13 or newer for the crsh
          remote storage scheme, but pkgs.ccache is ${pkgs.ccache.version}. An
          older ccache fails only once a build runs, with "unknown remote
          storage scheme: crsh".
        '';
      }
      {
        assertion = !(cfg.netrcFile != null && cfg.attributes ? "netrc-file");
        message = ''
          services.ccache-storage-http.netrcFile and the "netrc-file" entry of
          services.ccache-storage-http.attributes set the same thing. Use only
          one of them.
        '';
      }
    ];

    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        description = "ccache remote storage helper";
        isSystemUser = true;
        group = cfg.group;
      };
    };

    systemd.services.ccache-storage-http = {
      description = "ccache HTTP(S) remote storage helper";
      documentation = [ "https://ccache.dev/storage-helpers.html" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        CRSH_IPC_ENDPOINT = cfg.socketPath;
        CRSH_URL = cfg.url;
        # Never exit on idle: ccache cannot spawn a replacement through a
        # `crsh:` URL.
        CRSH_IDLE_TIMEOUT = "0";
        CRSH_NUM_ATTR = toString (builtins.length attrPairs);
      }
      // attrEnv
      // lib.optionalAttrs cfg.journalLog { CRSH_LOGFILE = "/dev/stderr"; };

      serviceConfig = {
        ExecStart =
          if cfg.journalLog then "${journalStartScript}" else lib.getExe' cfg.package "ccache-storage-http";
        ExecStartPost = lib.getExe openSocketScript;
        TimeoutStartSec = 30;
        Restart = "on-failure";
        RestartSec = 1;

        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = runtimeDirName;

        # Mounts are applied after the Protect* options, so this wins.
        BindReadOnlyPaths = attrFiles;

        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];
      };
    };

    nix.settings.system-features = [ cfg.systemFeature ];

    # The module cannot work without the hook, whose only effect is to install
    # nix.settings.pre-build-hook.
    programs.nix-required-mounts.enable = lib.mkDefault true;

    programs.nix-required-mounts.allowedPatterns.${cfg.systemFeature}.paths = [
      cfg.socketPath
      config.programs.ccache.cacheDir
    ];

    # mkAfter on both counts: programs.ccache replaces ccacheWrapper's
    # extraConfig wholesale and rebuilds packageNames against ccacheStdenv, and
    # we want to extend both results rather than race them.
    nixpkgs.overlays = lib.mkIf cfg.configureCcache (
      lib.mkAfter [
        (final: prev: {
          ccacheWrapper = prev.ccacheWrapper.override (old: {
            extraConfig = old.extraConfig + ''
              export CCACHE_REMOTE_STORAGE=${lib.escapeShellArg cfg.remoteStorage}
            '';
          });
        })

        # Doing this per package rather than through an stdenv adapter keeps the
        # existing requiredSystemFeatures intact -- some of these packages are
        # exactly the ones that ask for "big-parallel".
        (
          final: prev:
          lib.genAttrs config.programs.ccache.packageNames (
            name:
            prev.${name}.overrideAttrs (old: {
              requiredSystemFeatures = (old.requiredSystemFeatures or [ ]) ++ [ cfg.systemFeature ];
            })
          )
        )
      ]
    );
  };
}
