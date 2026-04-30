{
  lib,
  makeSetupHook,
  renpyMinimal,
}:

makeSetupHook {
  name = "renpy-build-hook";

  propagatedBuildInputs = [ renpyMinimal ];

  meta = {
    description = "Compile Ren'Py scripts in the existing source root";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
