# upstream alsa ships with PinePhone audio configs, but they don't actually produce sound.
# - still true as of 2024-08-20
# - see: <https://github.com/alsa-project/alsa-ucm-conf/pull/134>
# - see: <https://gitlab.com/postmarketOS/pmaports/-/issues/2115>
#
# alsa-ucm-pinephone-manjaro (2024-05-26):
# - headphones work
# - "internal earpiece" works
# - "internal speaker" is silent (maybe hardware issue)
# - 3.5mm connection is flapping when playing to my car, which eventually breaks audio and requires restarting wireplumber
# packageUnwrapped = pkgs.alsa-ucm-pinephone-manjaro.override {
#   inherit (cfg.config) preferEarpiece;
# };
# alsa-ucm-pinephone-pmos (2024-05-26):
# - headphones work
# - "internal earpiece" works
# - "internal speaker" is silent (maybe hardware issue)
# packageUnwrapped = pkgs.alsa-ucm-pinephone-pmos.override {
#   inherit (cfg.config) preferEarpiece;
# };
{ ... }:
{
  sane.programs.pine64-alsa-ucm = {
    sandbox.enable = false;  #< only provides /share/alsa
  };
}
