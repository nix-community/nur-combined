{ config, lib, ...}:
{
  sane.programs.steam = {
    persist.byStore.plaintext = [
      ".steam"
      ".local/share/Steam"
    ];
  };
  # steam requires system-level config for e.g. firewall or controller support
  programs.steam = lib.mkIf config.sane.programs.steam.enabled {
    enable = true;
    # not sure if needed: stole this whole snippet from the wiki
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}
