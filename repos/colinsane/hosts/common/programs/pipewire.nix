# administer with pw-cli, pw-mon, pw-top commands
#
# performance tuning: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Performance-tuning>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.pipewire;
in
{
  sane.programs.pipewire = {
     configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.min-quantum = mkOption {
          type = types.int;
          default = 16;
        };
        options.max-quantum = mkOption {
          type = types.int;
          default = 2048;
        };
      };
    };

    suggestedPrograms = [
      "rtkit"
      "wireplumber"
    ];

    # sandbox.method = "landlock";
    sandbox.method = "bwrap";  #< also works, but can't claim the full scheduling priority it wants
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [
      # dbus is used for rtkit integration
      # rtkit runs on the system bus.
      # xdg-desktop-portal then exposes this to the user bus.
      # therefore, user bus should be all that's needed, but...
      # xdg-desktop-portal-wlr depends on pipewire, hence pipewire has to start before xdg-desktop-portal.
      # then, pipewire has to talk specifically to rtkit (system) and not go through xdp.
      # "user"
      "system"
    ];
    sandbox.wrapperType = "inplace";  #< its config files refer to its binaries by full path
    sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"  #< required for rtkit
    ];
    # sandbox.capabilities = [
    #   # if rtkit isn't present, and sandboxing is via landlock, these capabilities allow pipewire to claim higher scheduling priority
    #   "ipc_lock"
    #   "sys_nice"
    # ];
    sandbox.usePortal = false;
    sandbox.extraPaths = [
      "/dev/snd"
      # desko/lappy don't need these, but moby complains if not present
      "/dev/video0"
      "/dev/video1"
      "/dev/video2"
    ];
    sandbox.extraHomePaths = [
      # pulseaudio cookie
      ".config/pulse"
      ".config/pipewire"
    ];

    # note the .conf.d approach: using ~/.config/pipewire/pipewire.conf directly breaks all audio,
    # presumably because that deletes the defaults entirely whereas the .conf.d approach selectively overrides defaults
    fs.".config/pipewire/pipewire.conf.d/10-sane-config.conf".symlink.text = ''
      # config docs: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#properties>
      # useful to run `pw-top` to see that these settings are actually having effect,
      # and `pw-metadata` to see if any settings conflict (e.g. max-quantum < min-quantum)
      #
      # restart pipewire after editing these files:
      # - `systemctl --user restart pipewire`
      # - pipewire users will likely stop outputting audio until they are also restarted
      #
      # there's seemingly two buffers for the mic (see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/FAQ#pipewire-buffering-explained>)
      # 1. Pipewire buffering out of the driver and into its own member.
      # 2. Pipewire buffering into each specific app (e.g. Dino).
      # note that pipewire default config includes `clock.power-of-two-quantum = true`
      context.properties = {
        default.clock.min-quantum = ${builtins.toString cfg.config.min-quantum}
        default.clock.max-quantum = ${builtins.toString cfg.config.max-quantum}
      }
    '';

    # see: <https://docs.pipewire.org/page_module_protocol_native.html>
    # defaults to placing the socket in /run/user/$id/{pipewire-0,pipewire-0-manager,...}
    # but that's trickier to sandbox
    env.PIPEWIRE_RUNTIME_DIR = "$XDG_RUNTIME_DIR/pipewire";

    services.pipewire = {
      description = "pipewire: multimedia service";
      partOf = [ "sound" ];
      # depends = [ "rtkit" ];
      # depends = [ "xdg-desktop-portal" ];  # for Realtime portal (dependency cycle)
      # env PIPEWIRE_LOG_SYSTEMD=false"
      # env PIPEWIRE_DEBUG"*:3,mod.raop*:5,pw.rtsp-client*:5"
      command = pkgs.writeShellScript "pipewire-start" ''
        mkdir -p $PIPEWIRE_RUNTIME_DIR
        exec pipewire
      '';
      readiness.waitExists = [
        "$PIPEWIRE_RUNTIME_DIR/pipewire-0"
        "$PIPEWIRE_RUNTIME_DIR/pipewire-0-manager"
      ];
      cleanupCommand = ''rm -f "$PIPEWIRE_RUNTIME_DIR/{pipewire-0,pipewire-0.lock,pipewire-0-manager,pipewire-0-manager.lock}"'';
    };
    services.pipewire-pulse = {
      description = "pipewire-pulse: Pipewire compatibility layer for PulseAudio clients";
      depends = [ "pipewire" ];
      partOf = [ "sound" ];
      command = pkgs.writeShellScript "pipewire-pulse-start" ''
        mkdir -p $XDG_RUNTIME_DIR/pulse
        exec pipewire-pulse
      '';
      readiness.waitExists = [
        "$XDG_RUNTIME_DIR/pulse/native"
        "$XDG_RUNTIME_DIR/pulse/pid"
      ];
      cleanupCommand = ''rm -f "$XDG_RUNTIME_DIR/pulse/{native,pid}"'';
    };
  };

  # taken from nixos/modules/services/desktops/pipewire/pipewire.nix
  # removed 32-bit compatibility stuff
  environment.etc = lib.mkIf cfg.enabled {
    "alsa/conf.d/49-pipewire-modules.conf".text = ''
      pcm_type.pipewire {
        libs.native = ${cfg.package}/lib/alsa-lib/libasound_module_pcm_pipewire.so ;
      }
      ctl_type.pipewire {
        libs.native = ${cfg.package}/lib/alsa-lib/libasound_module_ctl_pipewire.so ;
      }
    '';

    "alsa/conf.d/50-pipewire.conf".source = "${cfg.package}/share/alsa/alsa.conf.d/50-pipewire.conf";
    "alsa/conf.d/99-pipewire-default.conf".source = "${cfg.package}/share/alsa/alsa.conf.d/99-pipewire-default.conf";
  };

  services.udev.packages = lib.mkIf cfg.enabled [
    cfg.package
  ];
}
