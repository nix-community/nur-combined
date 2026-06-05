{ ... }:
{
  sane.programs.DTMFtool = {
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
  };
}
