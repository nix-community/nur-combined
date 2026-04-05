{
  lib,
  makeSetupHook,
  targetPackages,
  makeWrapper,
}:

makeSetupHook {
  name = "renpy-wrap-hook";

  propagatedBuildInputs = [ makeWrapper ];

  substitutions = {
    renpy = lib.getExe targetPackages.renpy;
  };

  meta = {
    description = "Setup hook for making an executable that uses Ren'Py to launch the game in $out/share or $out/opt";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
