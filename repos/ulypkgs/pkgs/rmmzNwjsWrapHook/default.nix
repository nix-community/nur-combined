{
  lib,
  makeSetupHook,
  targetPackages,
  makeWrapper,
  file,
  jq,
}:

makeSetupHook {
  name = "rmmz-nwjs-wrap-hook";

  propagatedBuildInputs = [
    makeWrapper
    file
    jq
  ];

  substitutions = {
    nwjs = lib.getExe targetPackages.nwjs;
    rmmzManagersPatch = ./fix-save-location.js;
  };

  meta = {
    description = "Setup hook for making an executable that uses NW.js to launch an RPG Maker MZ game in $out/share or $out/opt";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
