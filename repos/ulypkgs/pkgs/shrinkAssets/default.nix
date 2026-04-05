{
  lib,
  makeSetupHook,
  imagemagick,
  ffmpeg,
}:

makeSetupHook {
  name = "shrink-assets";

  propagatedBuildInputs = [
    imagemagick
    ffmpeg
  ];

  meta = {
    description = "Setup hook for shrinking assets in $out";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
