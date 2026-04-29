{
  lib,
  makeSetupHook,
  targetPackages,
  makeWrapper,
  file,
}:

makeSetupHook {
  name = "godot-wrap-hook";

  propagatedBuildInputs = [
    makeWrapper
    file
  ];

  substitutions = {
    godot = lib.getExe targetPackages.godot-runtime;
  };

  meta = {
    description = "Setup hook for making an executable that uses Godot to launch the game in $out/share or $out/opt";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
