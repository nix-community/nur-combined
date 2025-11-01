{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.system;
  commonOptions = {
    displaysleep = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "display sleep timer in minutes (0 to disable)";
    };
    disksleep = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "disk spindown timer in minutes (0 to disable)";
    };
    sleep = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "system sleep timer in minutes (0 to disable)";
    };
    womp = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "wake on ethernet magic packet. Same as 'Wake for network access' in System Settings.";
    };
    ring = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "wake on modem ring";
    };
    powernap = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "enable/disable Power Nap on supported machines";
    };
    proximitywake = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "On supported systems, this option controls system wake from sleep based on proximity of devices using same iCloud id.";
    };
    autorestart = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "automatic restart on power loss";
    };
    lidwake = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "wake the machine when the laptop lid (or clamshell) is opened";
    };
    acwake = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "wake the machine when power source (AC/battery) is changed";
    };
    lessbright = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "slightly turn down display brightness when switching to this power source";
    };
    halfdim = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "display sleep will use an intermediate half-brightness state between full brightness and fully off";
    };
    sms = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "use Sudden Motion Sensor to park disk heads on sudden changes in G force";
    };
    hibernatemode = mkOption {
      type = types.nullOr (
        types.enum [
          0
          3
          25
        ]
      );
      default = null;
      description = ''
        change hibernation mode. Please use caution.

        Whether or not a hibernation image gets written is also dependent on the
        values of standby and autopoweroff.

        For example, on desktops that support standby a hibernation image will
        be written after the specified standbydelay time. To disable hibernation
        images completely, ensure hibernatemode standby and autopoweroff are all
        set to 0.

        hibernatemode = 0 by default on desktops. The system will not back
        memory up to persistent storage. The system must wake from the contents
        of memory; the system will lose context on power loss. This is,
        historically, plain old sleep.

        hibernatemode = 3 by default on portables. The system will store a copy
        of memory to persistent storage (the disk), and will power memory during
        sleep. The system will wake from memory, unless a power loss forces it
        to restore from hibernate image.

        hibernatemode = 25 is only settable via pmset. The system will store a
        copy of memory to persistent storage (the disk), and will remove power
        to memory. The system will restore from disk image. If you want
        "hibernation" - slower sleeps, slower wakes, and better battery life,
        you should use this setting.
      '';
    };
    hibernatefile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = /var/vm/sleepimage;
      description = "change hibernation image file location. Image may only be located on the root volume. Please use caution.";
    };
    ttyskeepawake = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "prevent idle system sleep when any tty (e.g. remote login session) is 'active'. A tty is 'inactive' only when its idle time exceeds the system sleep timer.";
    };
    networkoversleep = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "this setting affects how OS X networking presents shared network services during system sleep. This setting is not used by all platforms; changing its value is unsupported.";
    };
    destroyfvkeyonstandby = mkOption {
      type = types.nullOr (
        types.enum [
          0
          1
        ]
      );
      default = null;
      description = "Destroy File Vault Key when going to standby mode. By default File vault keys are retained even when system goes to standby. If the keys are destroyed, user will be prompted to enter the password while coming out of standby mode. (1 = Destroy, 0 = Retain)";
    };
    standbydelay = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "delay, in seconds, before writing the hibernation image to disk and powering off memory for Standby. Used by desktops.";
    };
    standbydelayhigh = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "delay, in seconds, before writing the hibernation image to disk and powering off memory for Standby. Used when the remaining battery capacity is below highstandbythreshold.";
    };
    standbydelaylow = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = "delay, in seconds, before writing the hibernation image to disk and powering off memory for Standby. Used when the remaining battery capacity is above highstandbythreshold.";
    };
    highstandbythreshold = mkOption {
      type = types.nullOr (types.ints.between 0 100);
      default = null;
      example = 50;
      description = "battery capacity threshold that defines which delay a standby machine will use before hibernating. Defaults to 50 percent.";
    };
    autopoweroffdelay = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      example = 50;
      description = "delay, in seconds, before entering autopoweroff mode.";
    };
  };
  writePmset =
    flag: entries:
    strings.optionalString (
      (builtins.length entries) > 0
    ) "pmset ${flag} ${concatStringsSep " " entries}";
  pmsetSettingsToList =
    attrs: mapAttrsToList (k: v: "${k} ${builtins.toString v}") (filterAttrs (n: v: v != null) attrs);
  pmset = flag: attrs: writePmset flag (pmsetSettingsToList attrs);
in
{
  meta.maintainers = [
    maintainers.wwmoraes or "wwmoraes"
  ];

  options = {
    system.pmset.all = mkOption {
      type = types.nullOr (types.submodule { options = commonOptions; });
      default = { };
      example = {
        sleep = 0;
      };
      description = "A set of MacOS power management settings that applies to all energy sources.";
    };
    system.pmset.battery = mkOption {
      type = types.nullOr (types.submodule { options = commonOptions; });
      default = { };
      example = {
        sleep = 0;
      };
      description = "A set of MacOS power management settings that applies while on battery power.";
    };
    system.pmset.charger = mkOption {
      type = types.nullOr (types.submodule { options = commonOptions; });
      default = { };
      example = {
        sleep = 0;
      };
      description = "A set of MacOS power management settings that applies while on wall power.";
    };
    system.pmset.ups = mkOption {
      type = types.nullOr (
        types.submodule {
          options = commonOptions // {
            haltlevel = mkOption {
              type = types.nullOr (types.ints.between (-1) 100);
              default = null;
              description = "when draining UPS battery, battery level at which to trigger an emergency shutdown (value in %)";
            };
            haltafter = mkOption {
              type = types.nullOr (
                types.oneOf [
                  (-1)
                  types.ints.unsigned
                ]
              );
              default = null;
              description = "when draining UPS battery, trigger emergency shutdown after this long running on UPS power (value in minutes, or 0 to disable)";
            };
            haltremain = mkOption {
              type = types.nullOr (
                types.oneOf [
                  (-1)
                  types.ints.unsigned
                ]
              );
              default = null;
              description = "when draining UPS battery, trigger emergency shutdown when this much time remaining on UPS power is estimated (value in minutes, or 0 to disable)";
            };
          };
        }
      );
      default = { };
      example = {
        sleep = 0;
      };
      description = "A set of MacOS power management settings that applies while on UPS power.";
    };
  };
  config = {
    system.activationScripts.extraActivation.text = mkMerge [
      ''
        # pmset
        echo >&2 "power management settings..."
        ${pmset "-a" cfg.pmset.all}
        ${pmset "-b" cfg.pmset.battery}
        ${pmset "-c" cfg.pmset.charger}
        ${pmset "-u" cfg.pmset.ups}
      ''
    ];
  };
}
