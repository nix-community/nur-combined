# use like:
# - catt -d lgtv_chrome cast ./path/to.mp4
#
# support matrix:
# - webm: audio only
# - mp4: audio + video
{ config, lib, ... }:
let
  cfg = config.sane.programs.catt;
in
{
  sane.programs.catt = {
    fs.".config/catt/catt.cfg".symlink.text = ''
      [options]
      device = lgtv_chrome

      [aliases]
      lgtv_chrome = 10.78.79.106
    '';
  };

  # necessary to cast local files
  networking.firewall.allowedTCPPortRanges = lib.mkIf cfg.enabled [
    {
      from = 45000;
      to = 47000;
    }
  ];
}
