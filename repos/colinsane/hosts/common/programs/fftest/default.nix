# fftest can test the haptics/vibrator on a phone:
# - `fftest /dev/input/by-path/platform-vibrator-event`
{ ... }:
{
  sane.programs.fftest = {
    sandbox.autodetectCliPaths = "existing";
  };
}
