# fftest can test the haptics/vibrator on a phone:
# - `fftest /dev/input/by-path/platform-vibrator-event`
{ pkgs, ... }:
{
  sane.programs.fftest = {
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.linuxConsoleTools [
      "bin/fftest"
      "share/man/man1/fftest.1.gz"
    ];
    sandbox.autodetectCliPaths = "existing";
  };
}
