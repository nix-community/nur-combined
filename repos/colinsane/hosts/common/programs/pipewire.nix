# administer with pw-cli, pw-mon, pw-top commands
{ config, lib, ... }:
let
  cfg = config.sane.programs.pipewire;
in
{
  sane.programs.pipewire = {
    persist.byStore.plaintext = [
      # persist per-device volume levels
      ".local/state/wireplumber"
    ];
  };

  services.pipewire = lib.mkIf cfg.enabled {
    enable = true;
    package = cfg.package;
    alsa.enable = true;
    alsa.support32Bit = true;  # ??
    # emulate pulseaudio for legacy apps (e.g. sxmo-utils)
    pulse.enable = true;
    # TODO: try:
    # socketActivation = false;
  };
  systemd.user.services."pipewire".wantedBy = lib.optionals cfg.enabled [ "graphical-session.target" ];

  # rtkit/RealtimeKit: allow applications which want realtime audio (e.g. Dino? Pulseaudio server?) to request it.
  # this might require more configuration (e.g. polkit-related) to work exactly as desired.
  # - readme outlines requirements: <https://github.com/heftig/rtkit>
  # XXX(2023/10/12): rtkit does not play well on moby. any application sending audio out dies after 10s.
  # security.rtkit.enable = lib.mkIf cfg.enabled true;
}
