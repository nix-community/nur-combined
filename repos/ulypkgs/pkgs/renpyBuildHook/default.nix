{
  lib,
  makeSetupHook,
  renpy,
}:

makeSetupHook {
  name = "renpy-build-hook";

  propagatedBuildInputs = [ renpy ];

  meta = {
    description = "Compile Ren'Py scripts in the existing source root";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
