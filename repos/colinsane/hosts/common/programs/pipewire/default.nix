# administer with pw-cli, pw-mon, pw-top commands
#
# performance tuning: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Performance-tuning>
#
# HAZARDS FOR MOBY:
# - high-priority threads are liable to stall the lima GPU driver, and leave a half-functional OS state.
# - symptom is messages like this (with stack traces) in dmesg or journalctl:
#   - "[drm:lima_sched_timedout_job] *ERROR* lima job timeout"
#   - and the UI locks up for a couple seconds, and then pipewire + wireplumber crash (but not pipewire-pulse)
# - related, unconfirmed symptoms:
#   - "sched: RT throttling activated"
#   - "BUG: KFENCE: use-after-free read in vchan_complete"
#     - this one seems to be recoverable
# - likely to be triggered when using a small pipewire buffer (512 samples), by simple tasks like opening pavucontrol.
#   - but a lengthier buffer is no sure way to dodge it: it will happen (less frequently) even for buffers of 2048 samples.
# - seems ANY priority < 0 triggers this, independent of the `nice` setting.
#   - i only tried SCHED_FIFO, not SCHED_RR (round robin) for the realtime threads.
# - solution is some combination of:
#   - DON'T USE RTKIT. rtkit only supports SCHED_FIFO and SCHED_RR: there's no way to use it only for adjusting `nice` values.
#   - in pipewire.conf, remove all reference to libpipewire-module-rt.
#     - it's loaded by default. i can either provide a custom pipewire.conf which doesn't load it, or adjust its config so that it intentionally fails.
#     - without rtkit working, pipewire's module-rt doesn't allow niceness < -11. adjusting `nice`ness here seems to have little effect anyway.
# - longer term, rtkit (or just rlimit based pipewire module-rt) would be cool to enable: it *does* reduce underruns.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.pipewire;
in
{
  imports = [
    ./sofa-default.nix
  ];

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

    packageUnwrapped = pkgs.pipewire.override {
      # disabling systemd causes pipewire to be built with direct udev support instead.
      # i added this probably because i don't use system'd logind?
      enableSystemd = false;
    };

    suggestedPrograms = [
      # "rtkit"
      "sofa-default"
      "wireplumber"
    ];

    sandbox.whitelistAudio = true;
    # dbus is used for rtkit integration
    # rtkit runs on the system bus.
    # xdg-desktop-portal then exposes this to the user bus.
    # therefore, user bus should be all that's needed, but...
    # xdg-desktop-portal-wlr depends on pipewire, hence pipewire has to start before xdg-desktop-portal.
    # then, pipewire has to talk specifically to rtkit (system) and not go through xdp.
    # "system"  #< not required UNLESS i want rtkit integration
    sandbox.whitelistDbus.user = true;  #< required for camera sharing, especially through xdg-desktop-portal, e.g. `snapshot` application  (TODO: reduce)
    sandbox.wrapperType = "inplace";  #< its config files refer to its binaries by full path
    sandbox.keepPidsAndProc = true;  #< TODO: why?
    sandbox.whitelistAvDev = true;
    sandbox.capabilities = [
      # if rtkit isn't present, and sandboxing is via landlock, these capabilities allow pipewire to claim higher scheduling priority
      "ipc_lock"
      "sys_nice"
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
      # - <repo:pipewire/pipewire:src/daemon/pipewire.conf.in>
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
    fs.".config/pipewire/pipewire.conf.d/20-virtual.conf".symlink.target = ./20-virtual.conf;
    fs.".config/pipewire/pipewire.conf.d/20-spatializer-7.1.conf".symlink.target = ./20-spatializer-7.1.conf;

    # reduce realtime scheduling priority to prevent GPU instability,
    # but see the top of this file for other solutions.
    # fs.".config/pipewire/pipewire.conf.d/20-sane-rtkit.conf".symlink.text = ''
    #   # documented inside <repo:pipewire/pipewire:/src/modules/module-rt.c>
    #   context.modules = [{
    #     name = libpipewire-module-rt
    #     args = {
    #       nice.level   = 0
    #       rt.prio      = 0
    #       #rt.time.soft = -1
    #       #rt.time.hard = -1
    #       rlimits.enabled = false
    #       rtportal.enabled = false
    #       rtkit.enabled = true
    #       #uclamp.min = 0
    #       #uclamp.max = 1024
    #     }
    #     flags = [ ifexists nofail ]
    #   }]
    # '';
    # fs.".config/pipewire/pipewire-pulse.conf.d/20-sane-rtkit.conf".symlink.text = ''
    #   # documented: <repo:pipewire/pipewire:src/daemon/pipewire-pulse.conf.in>
    #   context.modules = [{
    #     name = libpipewire-module-rt
    #     args = {
    #       nice.level   = 0
    #       rt.prio      = 0
    #       #rt.time.soft = -1
    #       #rt.time.hard = -1
    #       rlimits.enabled = false
    #       rtportal.enabled = false
    #       rtkit.enabled = true
    #       #uclamp.min = 0
    #       #uclamp.max = 1024
    #     }
    #     flags = [ ifexists nofail ]
    #   }]
    # '';

    # see: <https://docs.pipewire.org/page_module_protocol_native.html>
    # defaults to placing the socket in $XDG_RUNTIME_DIR/{pipewire-0,pipewire-0-manager,...}
    # but that's trickier to sandbox
    env.PIPEWIRE_RUNTIME_DIR = "$XDG_RUNTIME_DIR/pipewire";

    services.pipewire = {
      description = "pipewire: multimedia service";
      partOf = [ "sound" ];
      # depends = [ "rtkit" ];
      # depends = [ "xdg-desktop-portal" ];  # for Realtime portal (dependency cycle)
      # env PIPEWIRE_LOG_SYSTEMD=false"
      # env PIPEWIRE_DEBUG="*:3,mod.raop*:5,pw.rtsp-client*:5"
      command = pkgs.writeShellScript "pipewire-start" ''
        mkdir -p ''${PIPEWIRE_RUNTIME_DIR}
        # nice -n -21 comes from pipewire defaults (niceness: -11)
        PIPEWIRE_DEBUG=3 exec nice -n -21 pipewire
      '';
      readiness.waitExists = [
        ''''${PIPEWIRE_RUNTIME_DIR}/pipewire-0''
        ''''${PIPEWIRE_RUNTIME_DIR}/pipewire-0-manager''
      ];
      cleanupCommand = ''rm -f "''${PIPEWIRE_RUNTIME_DIR}/{pipewire-0,pipewire-0.lock,pipewire-0-manager,pipewire-0-manager.lock}"'';
    };
    services.pipewire-pulse = {
      description = "pipewire-pulse: Pipewire compatibility layer for PulseAudio clients";
      depends = [ "pipewire" ];
      partOf = [ "sound" ];
      command = pkgs.writeShellScript "pipewire-pulse-start" ''
        mkdir -p ''${XDG_RUNTIME_DIR}/pulse
        exec nice -n -21 pipewire-pulse
      '';
      readiness.waitExists = [
        ''''${XDG_RUNTIME_DIR}/pulse/native''
        ''''${XDG_RUNTIME_DIR}/pulse/pid''
      ];
      cleanupCommand = ''rm -f "''${XDG_RUNTIME_DIR}/pulse/{native,pid}"'';
    };

    # bring up sound by default
    services."sound".partOf = [ "default" ];
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
