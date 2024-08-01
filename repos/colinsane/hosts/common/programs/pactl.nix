{ pkgs, ... }:
{
  sane.programs.pactl = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.pulseaudio "pactl";
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
  };
}
