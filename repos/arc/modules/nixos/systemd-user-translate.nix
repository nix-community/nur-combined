{ pkgs, config, lib, utils, ... }: with lib; let
  cfg = config.systemd.translate;
  arc'lib = import ../../lib { inherit lib; };
  unmerged = lib.unmerged or arc'lib.unmerged;
  systemctl = "${config.systemd.package}/bin/systemctl";
  matchSystemdName = builtins.match ''([^.]+)\.([^.]+)'';
  parseSystemdNameWithDefault = default: name: let
    matched = matchSystemdName name;
  in (if matched != null then {
    name = elemAt matched 0;
    type = elemAt matched 1;
  } else {
    inherit name;
    type = default;
  }) // {
    __toString = self: "${self.name}.${self.type}";
  };
  parseSystemdName = name: parseSystemdNameWithDefault (throw ''failed to parse "${name}" as a systemd unit'') name;
  users = mapAttrsToList (_: user: {
    inherit user;
    inherit (user.systemd) translate;
  }) (filterAttrs (_: user: user.systemd.translate.enable) config.users.users);
  systemUsers = attrValues (filterAttrs (_: user: user.systemd.translate.system.enable) config.users.users);
  coerceUnits = module: with types; coercedTo
    (oneOf [ (listOf (oneOf [ attrs str ])) str ])
    (units: listToAttrs (map (v: nameValuePair v.unit or v (if ! str.check v then v else {})) (toList units)))
    (attrsOf module);

  defaultTargetSettings = {
    unitConfig = {
      X-OnlyManualStart = true;
    };
  };
  defaultServiceSettings = {
    restartIfChanged = false;
    stopIfChanged = false;
    unitConfig = {
      RefuseManualStart = true;
      RefuseManualStop = true;
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutSec = "5m";
    };
  };

  translatedUserUnit = user: types.submodule ({ config, name, ... }: {
    options = with types; {
      #enable = mkEnableOption "translated user unit" // { default = true; };
      unit = mkOption {
        type = coercedTo str parseSystemdName attrs;
        default = name;
      };
      systemTarget = {
        name = mkOption {
          type = coercedTo str (parseSystemdNameWithDefault "target") attrs;
          default = "${user.name}-${config.unit.name}";
        };
        settings = mkOption {
          type = unmerged.types.attrs;
        };
      };
      userService = {
        name = mkOption {
          type = coercedTo str (parseSystemdNameWithDefault "service") attrs;
          default = "translate-${config.unit.name}";
        };
        settings = mkOption {
          type = unmerged.types.attrs;
        };
      };
      ordering = mkOption {
        type = enum [ "before" "after" ];
        default = "after";
      };
      systemStrength = mkOption {
        type = enum [ "wantedBy" "requiredBy" ];
        default = "wantedBy";
      };
    };
    config = {
      systemTarget.settings = defaultTargetSettings;
      userService.settings = mkMerge [ defaultServiceSettings rec {
        ${config.systemStrength} = bindsTo;
        bindsTo = [ (toString config.unit) ];
        ${config.ordering} = bindsTo;
        serviceConfig = {
          ExecStart = singleton "${systemctl} start ${utils.escapeSystemdExecArg (toString config.systemTarget.name)}";
          ExecStop = singleton "${systemctl} stop ${utils.escapeSystemdExecArg (toString config.systemTarget.name)}";
        };
      } ];
    };
  });

  translatedSystemUnit = let
    systemctl-user = pkgs.writeShellScript "systemctl-user-translate" ''
      if ${systemctl} --user --wait is-system-running > /dev/null; then
          ${systemctl} --user --no-block "$1" "$2"
      fi
    '';
  in types.submodule ({ config, name, ... }: {
    options = with types; {
      #enable = mkEnableOption "translated system unit" // { default = true; };
      unit = mkOption {
        type = coercedTo str parseSystemdName attrs;
        default = name;
      };
      systemService = {
        name = mkOption {
          type = coercedTo str (parseSystemdNameWithDefault "service") attrs;
          default = "translate-${config.unit.name}@";
        };
        settings = mkOption {
          type = unmerged.types.attrs;
        };
      };
      userTarget = {
        name = mkOption {
          type = coercedTo str (parseSystemdNameWithDefault "target") attrs;
          default = "system-${config.unit.name}";
        };
        settings = mkOption {
          type = unmerged.types.attrs;
        };
      };
      ordering = mkOption {
        type = enum [ "before" "after" ];
        default = "after";
      };
    };
    config = {
      userTarget.settings = defaultTargetSettings;
      systemService.settings = mkMerge [ defaultServiceSettings rec {
        bindsTo = [ (toString config.unit) ];
        ${config.ordering} = bindsTo;
        serviceConfig = let
        in {
          Environment = [
            "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%I/bus"
          ];
          User = "%I";
          ExecStart = singleton "${systemctl-user} start ${utils.escapeSystemdExecArg (toString config.userTarget.name)}";
          ExecStop = singleton "${systemctl-user} stop ${utils.escapeSystemdExecArg (toString config.userTarget.name)}";
        };
      } ];
    };
  });

  userModule = { config, ... }: let
    cfg = config.systemd.translate;
  in {
    options = with types; {
      systemd.translate = {
        enable = mkEnableOption "systemd user units" // {
          default = config.isNormalUser && config.systemd.translate.units != { };
        };
        system.enable = mkEnableOption "systemd system units" // {
          default = cfg.enable;
        };
        units = mkOption {
          type = coerceUnits (translatedUserUnit config);
          default = { };
          description = ''
            User units to mirror the state of globally.

            For example, this can generate a someuser-pipewire.target on the system bus,
            notifying others whenever someuser starts or stops their personal pipewire.service
          '';
          example = [ "pipewire.service" ];
        };
      };
    };
  };
in {
  options = with types; {
    users.users = mkOption {
      type = attrsOf (submodule userModule);
    };
    systemd.translate = {
      enable = mkEnableOption "translate" // { default = cfg.units != { }; };
      defaultTargets = mkOption {
        type = bool;
        default = true;
      };
      units = mkOption {
        type = coerceUnits translatedSystemUnit;
        default = { };
      };
    };
  };
  config = let
    mapUnitsOf = type: mapAttrs' (_: mapSystemUnit) (filterAttrs (_: u: u.unit.type == type) cfg.units);
    mapSystemUnit = unit: nameValuePair unit.unit.name (mkMerge (map (user: assert user.uid != null; rec {
      wants = [ "${unit.systemService.name.name}${toString user.uid}.service" ];
      #unitConfig.PropagatesStopTo = wants;
    }) systemUsers));
  in {
    systemd.translate.units = let
      normalTargets = [
        "network.target"
        "network-pre.target"
        "network-online.target"
        "time-sync.target"
        "graphical.target"
        "display-manager.service"
        "bluetooth.target"
      ];
      stopTargets = [
        "kexec.target"
        "poweroff.target"
        "shutdown.target"
        "hibernate.target"
        "reboot.target"
        "suspend.target"
        "sleep.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
        "umount.target"
      ];
      mapDefault = stop: unit: {
        inherit unit;
        userTarget = {
          inherit (parseSystemdName unit) name;
        };
        ${if stop then "ordering" else null} = "before";
      };
    in mkIf (cfg.defaultTargets) (
      map (mapDefault false) normalTargets
      ++ map (mapDefault true) stopTargets
    );
    systemd.targets = mkMerge [
      (listToAttrs (concatMap ({ user, translate }:
        mapAttrsToList (_: unit: nameValuePair unit.systemTarget.name.name
          (unmerged.mergeAttrs unit.systemTarget.settings)
        ) translate.units
      ) users))
      (mapUnitsOf "target")
    ];
    systemd.services = mkMerge [
      (mapUnitsOf "service")
      (listToAttrs (mapAttrsToList (_: unit: nameValuePair unit.systemService.name.name
        (unmerged.mergeAttrs unit.systemService.settings)
      ) cfg.units))
    ];
    systemd.user = {
      services = listToAttrs (concatMap ({ user, translate }:
        mapAttrsToList (_: unit: nameValuePair unit.userService.name.name
          (unmerged.mergeAttrs unit.userService.settings)
        ) translate.units
      ) users) // {
        systemd-translate = mkIf cfg.enable {
          wantedBy = [ "basic.target" "default.target" ];
          before = [ "default.target" ];
          script = ''
            USER=$(${pkgs.coreutils}/bin/id -un)
            if ! echo ${toString (map (u: u.name) systemUsers)} | ${pkgs.gnugrep}/bin/grep -wq "$USER"; then
              # this user doesn't care
              exit 0
            fi
          '' + concatStringsSep "\n" (mapAttrsToList (_: unit: ''
            if ${systemctl} is-active ${escapeShellArg unit.unit} > /dev/null; then
              ${systemctl} --user start ${escapeShellArg unit.userTarget.name}
            fi
          '') cfg.units);
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };
      };
      targets = listToAttrs (mapAttrsToList (_: unit: nameValuePair unit.userTarget.name.name
        (unmerged.mergeAttrs unit.userTarget.settings)
      ) cfg.units);
    };
    security.polkit.users = listToAttrs (map ({ user, translate }: nameValuePair user.name {
      systemd.units = mapAttrsToList (_: unit: toString unit.systemTarget.name) translate.units;
    }) users);
  };
}
