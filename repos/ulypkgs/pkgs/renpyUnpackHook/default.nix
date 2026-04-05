{
  lib,
  makeSetupHook,
  rpatool,
}:

makeSetupHook {
  name = "renpy-unpack-hook";

  propagatedBuildInputs = [ rpatool ];

  meta = {
    description = "Setup hook for unpacking Ren'Py archives (.rpa/.rpi files) in the existing source root";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
