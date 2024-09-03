{ pkgs, ... }:
{
  sane.programs.pactl = {
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.pulseaudio "pactl";
    sandbox.method = "bunpen";
    sandbox.whitelistAudio = true;
  };
}
