{
  lib,
  makeSetupHook,
  imagemagick,
}:

makeSetupHook {
  name = "resize-icons";

  propagatedBuildInputs = [ imagemagick ];

  meta = {
    description = "Setup hook to resize icons in $out/share/icons/hicolor to smaller sizes";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
