{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.swayidle;
  idleAction = with lib; types.submodule ({ config, name, ... }: {
    options.enable = mkEnableOption "invoke ${name} when sway is idle for so long";
    options.command = mkOption {
      type = types.str;
      default = name;
      description = ''
        shell command to run, e.g. "swaylock --indicator-idle-visible".
      '';
    };
    options.desktop = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        name of a .desktop file to launch, e.g. "swaylock.desktop".
      '';
    };
    options.service = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        name of a user service to start.
      '';
    };
    options.delay = mkOption {
      type = types.int;
      description = ''
        how many seconds of idle time before triggering the command.
      '';
    };
    config.command = lib.mkMerge [
      (lib.mkIf (config.desktop != null) (
        lib.escapeShellArgs [ "sane-open" "--application" "${config.desktop}" ])
      )
      (lib.mkIf (config.service != null) (
        lib.escapeShellArgs [ "systemctl" "start" "${config.service}" ])
      )
    ];
  });
  screenOff = pkgs.writeShellScriptBin "screen-off" ''
    swaymsg -- output '*' power false
    # XXX(2024/06/09): `type:touch` method is documented, but now silently fails
    # swaymsg -- input type:touch events disabled

    inputs=$(swaymsg -t get_inputs --raw | jq '. | map(select(.type == "touch")) | map(.identifier) | join(" ")' --raw-output)
    for id in "''${inputs[@]}"; do
      swaymsg -- input "$id" events disabled
    done
  '';
in
{
  sane.programs.swayidle = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.actions = mkOption {
          type = types.attrsOf idleAction;
          default = {};
        };
      };
    };

    config.actions.screenoff = {
      # XXX: this turns the screen/touch off, and then there's no way to turn it back ON
      # unless you've configured that elsewhere (e.g. sane-input-handler)
      enable = lib.mkDefault false;
      command = lib.getExe screenOff;
      delay = lib.mkDefault 1500;  # 1500s = 25min
    };
    config.actions.lock = {
      # define a well-known action mostly to prevent accidentally shipping overlapping screen lockers...
      delay = lib.mkDefault 1800;  # 1800 = 30min
      # enable by default, but only if something else has installed a locker.
      enable = lib.mkDefault cfg.actions.lock.command != "";
      command = lib.mkDefault "";
    };

    suggestedPrograms = [
      "jq"
      # "sway"  #< required, but circular dep
    ];

    sandbox.whitelistDbus = [
      "user"  #< ??
    ];
    sandbox.whitelistSystemctl = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = null;  # not a GUI even though it uses wayland
    sandbox.extraRuntimePaths = [ "sway" ];

    services.swayidle = {
      description = "swayidle: perform actions when sway session is idle";
      partOf = [ "graphical-session" ];

      command = lib.escapeShellArgs (
        [
          "swayidle"
          "-w"
        ] ++ lib.flatten (
          lib.mapAttrsToList
            (_: { command, delay, enable, ... }: lib.optionals enable [
              "timeout"
              (builtins.toString delay)
              command
            ])
            cfg.config.actions
        )
      );
    };
  };
}
