{ ... }:
{
  sane.programs.coppwr = {
    sandbox.whitelistAudio = true;
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/coppwr/mesa";
  };
}
