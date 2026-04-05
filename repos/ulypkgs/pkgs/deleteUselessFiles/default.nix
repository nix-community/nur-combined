{
  lib,
  makeSetupHook,
}:

makeSetupHook {
  name = "delete-useless-files";

  meta = {
    description = "Setup hook for deleting useless files in $out";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
