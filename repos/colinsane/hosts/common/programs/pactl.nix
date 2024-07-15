{ pkgs, ... }:
{
  sane.programs.pactl = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.pulseaudio "bin/pactl";
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
  };
}
