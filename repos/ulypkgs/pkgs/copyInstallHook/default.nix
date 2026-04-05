{
  lib,
  makeSetupHook,
}:

makeSetupHook {
  name = "copy-install-hook";

  meta = {
    description = "Setup hook to copy the contents of src to $out";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
