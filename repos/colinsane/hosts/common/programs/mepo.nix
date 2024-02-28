# docs: <https://git.sr.ht/~mil/mepo>
# irc #mepo:irc.oftc.net
{ config, lib, ... }:

{
  sane.programs.mepo = {
    sandbox.method = "bwrap";
    sandbox.net = "all";  # for tiles *and* for localhost comm to gpsd
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  # for geoclue

    persist.byStore.plaintext = [ ".cache/mepo/tiles" ];
    # ~/.cache/mepo/savestate has precise coordinates and pins: keep those private
    persist.byStore.private = [
      { type = "file"; path = ".cache/mepo/savestate"; }
    ];

    # give mepo access to gpsd for location data, if that's enabled.
    # same with geoclue2.
    suggestedPrograms = lib.optional config.services.gpsd.enable "gpsd"
      ++ lib.optional config.services.geoclue2.enable "geoclue2-with-demo-agent"
    ;
  };

  # programs.mepo = lib.mkIf config.sane.programs.mepo.enabled {
  #   # enable location services (via geoclue)
  #   enable = true;
  #   # more precise, via gpsd ("may require additional config")
  #   # programs.mepo.gpsd.enable = true
  # };
}
