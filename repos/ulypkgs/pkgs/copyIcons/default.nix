{
  lib,
  makeSetupHook,
  imagemagick,
}:

makeSetupHook {
  name = "copy-icons";

  propagatedBuildInputs = [ imagemagick ];

  meta = {
    description = "Setup hook to copy icons in $icon or $icons to $out/share/icons/hicolor";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
