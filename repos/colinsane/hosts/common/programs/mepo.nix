# docs: <https://git.sr.ht/~mil/mepo>
# irc #mepo:irc.oftc.net
#
{ config, lib, ... }:
{
  sane.programs.mepo = {
    sandbox.method = "bwrap";
    sandbox.net = "all";  # for tiles *and* for localhost comm to gpsd
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [
      "system"  # system is required for non-portal location services
      "user"  #< not sure if "user" is necessary?
    ];
    sandbox.usePortal = false;  # TODO: set up portal-based location services

    persist.byStore.plaintext = [ ".cache/mepo/tiles" ];
    # ~/.cache/mepo/savestate has precise coordinates and pins: keep those private
    persist.byStore.private = [
      { type = "file"; path = ".cache/mepo/savestate"; }
    ];

    # enable geoclue2 and gpsd for location data.
    suggestedPrograms = [
      "geoclue2"
      # "gpsd"  #< not required, and mepo only uses it if geoclue is unavailable
    ];
  };

  # programs.mepo = lib.mkIf config.sane.programs.mepo.enabled {
  #   # enable location services (via geoclue)
  #   enable = true;
  #   # more precise, via gpsd ("may require additional config")
  #   # programs.mepo.gpsd.enable = true
  # };
}
