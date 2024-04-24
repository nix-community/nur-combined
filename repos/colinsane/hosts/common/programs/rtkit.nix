# rtkit/RealtimeKit: allow applications which want realtime audio (e.g. Dino? Pulseaudio server?) to request it.
# this might require more configuration (e.g. polkit-related) to work exactly as desired.
# - readme outlines requirements: <https://github.com/heftig/rtkit>
# XXX(2023/10/12): rtkit does not play well on moby. any application sending audio out dies after 10s.
# - note that `rtkit-daemon` can be launched with a lot of config
#   - suggest using a much less aggressive canary. maybe try that?
#   - see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Performance-tuning>
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.rtkit;
in
{
  sane.programs.rtkit = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.rtkit;
    # services.rtkit = {
    #   description = "rtkit: grant realtime scheduling privileges to select processes";
    #   command = "${cfg.package}/libexec/rtkit-daemon";
    # };
  };

  systemd.services.rtkit-daemon = lib.mkIf cfg.enabled {
    description = "rtkit: grant realtime scheduling privileges to select processes";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        "${cfg.package}/libexec/rtkit-daemon"
        "--scheduling-policy=FIFO"
        "--our-realtime-priority=79"
        "--max-realtime-priority=78"  # N.B.: setting this too aggressively can hang weak devices!
        "--min-nice-level=-19"
        "--rttime-usec-max=2000000"
        "--users-max=100"
        "--processes-per-user-max=1000"
        "--threads-per-user-max=10000"
        "--actions-burst-sec=10"
        "--actions-per-burst-max=1000"
        "--canary-cheep-msec=30000"
        "--canary-watchdog-msec=60000"
      ];

      Type = "simple";
      # Type = "dbus";
      # BusName = "org.freedesktop.RealtimeKit1";
      Restart = "on-failure";
      # User = "rtkit";  # it wants starts as root
      # Group = "rtkit";
      # wantedBy = [ "default.target" ];
      # TODO: harden
      CapabilityBoundingSet = "CAP_SYS_NICE CAP_DAC_READ_SEARCH CAP_SYS_CHROOT CAP_SETGID CAP_SETUID";
    };
  };
  users.users.rtkit = lib.mkIf cfg.enabled {
    isSystemUser = true;
    group = "rtkit";
    description = "RealtimeKit daemon";
  };
  users.groups.rtkit = lib.mkIf cfg.enabled {};


  environment.systemPackages = lib.mkIf cfg.enabled [
    # for /share/polkit-1, but unclear if actually needed
    cfg.package
  ];
  security.polkit = lib.mkIf cfg.enabled {
    enable = true;
  };
}
