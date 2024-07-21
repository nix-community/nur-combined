# libmysofa Head Related Transfer Function file to use to downmix surround -> stereo.
# use a HRTF tuned for my skull/ears, and i can get 5.1 or 7.1 sources to still
# sound real, when played over headphones.
#
# file is installed to /etc/profiles/per-user/colin/share/libmysofa/default.sofa
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sofa-default;
in
{
  sane.programs.sofa-default = {
    packageUnwrapped = pkgs.sofacoustics.listen.irc_1052.asDefault;
    sandbox.enable = false;  #< data only
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/libmysofa"
  ];
}
