# docs: <https://git.sr.ht/~mil/mepo>
# irc #mepo:irc.oftc.net
{ config, lib, ... }:

{
  sane.programs.mepo = {
    persist.plaintext = [ ".cache/mepo/tiles" ];
    # ~/.cache/mepo/savestate has precise coordinates and pins: keep those private
    persist.private = [
      { type = "file"; path = ".cache/mepo/savestate"; }
    ];
  };

  programs.mepo = lib.mkIf config.sane.programs.mepo.enabled {
    # enable location services (via geoclue)
    enable = true;
    # more precise, via gpsd ("may require additional config")
    # programs.mepo.gpsd.enable = true
  };
}
