{
  lib,
  makeSetupHook,
  rpatool,
}:

makeSetupHook {
  name = "renpy-pack-hook";

  propagatedBuildInputs = [ rpatool ];

  meta = {
    description = "Setup hook for packing Ren'Py archives (.rpa/.rpi files) for installed games";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
