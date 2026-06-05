{ pkgs, ... }:
{
  sane.programs.pactl = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.pulseaudio "pactl";
    sandbox.whitelistAudio = true;
  };
}
