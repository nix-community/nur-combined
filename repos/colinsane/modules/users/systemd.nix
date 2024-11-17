{ config, lib, pkgs, sane-lib, ... }:
let
  toUnitName = s:
    # TODO: i could query `services."${s}".command` to figure out here if it's
    # a target or a service, rather than hardcode it.
    if lib.elem s [ "default" "graphical-session" "gps" "private-storage" "sound" "wayland" "x11" ] then
      "${s}.target"
    else
      "${s}.service"
  ;
  toUnitNames = lib.map toUnitName;
  mkSystemdUnit = {
    description,
    documentation,
    depends,
    dependencyOf,
    partOf,
    ...
  }: {
    inherit description documentation;
    wants = toUnitNames depends;
    after = toUnitNames depends;
    wantedBy = (toUnitNames dependencyOf) ++ (toUnitNames partOf);
    before = (toUnitNames dependencyOf) ++ (toUnitNames partOf);
  };
  mkSystemdService = userName: userConfig: _serviceName: {
    # description,
    # documentation,
    # depends,
    # dependencyOf,
    # partOf,
    command,
    cleanupCommand,
    startCommand,
    readiness,  # readiness.waitCommand, readiness.waitDbus, readiness.waitExists
    restartCondition,
    ...
  }: lib.mkMerge [
    {
      # serviceConfig.BoundBy = toUnitNames partOf;
      # serviceConfig.Restart = restartCondition;  #< not allowed for `oneshot` types

      serviceConfig.User = userName;
      serviceConfig.Group = "users";
      serviceConfig.WorkingDirectory = "~";
      serviceConfig.X-RestartIfChanged = lib.mkDefault false;  #< NixOS attribute, so we don't restart the DE on activation

      serviceConfig.ExecSearchPath = [
        "/etc/profiles/per-user/${userName}/bin"
        "/run/current-system/sw/bin"
      ];
      path = [
        "/etc/profiles/per-user/${userName}"
        "/run/current-system/sw"
      ];
      # systemd doesn't allow substitutions, so perform one layer of substitution over the environment.
      # especially, this lets me base environment variables off of XDG dirs (like XDG_RUNTIME_DIR).
      environment = lib.mapAttrs
        (k: v: lib.replaceStrings
          (lib.mapAttrsToList (var: value: "$" + var) userConfig.environment)
          (lib.mapAttrsToList (var: value: value) userConfig.environment)
          v
        )
        userConfig.environment;
    }
    (lib.mkIf (command != null && readiness.waitCommand == null) {
      serviceConfig.Type = "simple";
      serviceConfig.Restart = restartCondition;
      serviceConfig.ExecStart = command;
    })
    (lib.mkIf (command != null && readiness.waitCommand != null) {
      serviceConfig.Type = "notify";
      serviceConfig.Restart = restartCondition;
      # serviceConfig.NotifyAccess = "exec";  #< allow anything in Exec* to invoke systemd-notify
      serviceConfig.NotifyAccess = "all";  #< allow anything in Exec* to invoke systemd-notify
      script = ''
        isReady() {
          echo "checking readiness..."
          ${readiness.waitCommand}
        }
        readinessPollLoop() {
          while ! isReady; do
            echo "service is not ready: sleeping 1s"
            ${lib.getExe' pkgs.coreutils "sleep"} 1
          done
          echo "ready: notifying systemd"
          ${lib.getExe' pkgs.systemd "systemd-notify"} --ready
        }

        readinessPollLoop &
        ${command}
        exit $?
      '';
    })
    (lib.mkIf (startCommand != null) {
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      serviceConfig.ExecStart = startCommand;
    })
    (lib.mkIf (cleanupCommand != null) {
      serviceConfig.ExecStopPost = cleanupCommand;
      serviceConfig.TimeoutStopSec = "30s";  #< system-wide default is closer to 10s, but eg25-control-powered takes longer than that
    })
  ];

  mkSystemd = enable: userName: userConfig: unitName: unitConfig: let
    unit = mkSystemdUnit unitConfig;
    service = mkSystemdService userName userConfig unitName unitConfig;
    isService = unitConfig.command != null || unitConfig.startCommand != null;
    # isService = (service.serviceConfig.Type or null) != null;
  in {
    # XXX: can't use `systemd.units ... = unit` because it doesn't expose `after`
    systemd.services = lib.optionalAttrs (enable && isService) {
      "${unitName}" = lib.mkMerge [ unit service ];
    };
    # systemd complains if you manually define `default.target`, so omit that particular one
    systemd.targets = lib.optionalAttrs (enable && !isService && unitName != "default") {
      "${unitName}" = unit;
    };
  };

  configsForUser = userName: userConfig: let
    globalEn = userConfig.default && userConfig.serviceManager == "systemd";
  in
    lib.mapAttrsToList (mkSystemd globalEn userName userConfig) userConfig.services
  ;
in
{
  config = let
    configs = lib.flatten (lib.mapAttrsToList configsForUser config.sane.users);
    take = f: {
      systemd.services = f.systemd.services;
      systemd.targets = f.systemd.targets;
    };
  in lib.mkMerge [
    (take (sane-lib.mkTypedMerge take configs))
  ];
  # systemd.services = lib.mkMerge (lib.mapAttrsToList servicesForUser config.sane.users);
}
