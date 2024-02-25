# administer with pw-cli, pw-mon, pw-top commands
{ config, lib, ... }:
let
  cfg = config.sane.programs.pipewire;
in
{
  sane.programs.pipewire = {
    suggestedPrograms = [ "wireplumber" ];

    # sandbox.method = "landlock";  #< also works
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  #< its config files refer to its binaries by full path
    sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"
    ];
    sandbox.usePortal = false;
    # needs to *create* the various device files, so needs write access to the /run/user/$uid directory itself
    sandbox.extraRuntimePaths = [ "/" ];
    sandbox.extraPaths = [
      "/dev/snd"
    ];
    sandbox.extraHomePaths = [
      # pulseaudio cookie
      ".config/pulse"
    ];

    services.pipewire = {
      description = "pipewire: multimedia service";
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pipewire";
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
      };
    };
    services.pipewire-pulse = {
      description = "pipewire-pulse: Pipewire compatibility layer for PulseAudio clients";
      after = [ "pipewire.service" ];
      wantedBy = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pipewire-pulse";
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";
      };
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

  # rtkit/RealtimeKit: allow applications which want realtime audio (e.g. Dino? Pulseaudio server?) to request it.
  # this might require more configuration (e.g. polkit-related) to work exactly as desired.
  # - readme outlines requirements: <https://github.com/heftig/rtkit>
  # XXX(2023/10/12): rtkit does not play well on moby. any application sending audio out dies after 10s.
  # security.rtkit.enable = lib.mkIf cfg.enabled true;
}
