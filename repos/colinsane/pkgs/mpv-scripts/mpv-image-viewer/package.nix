# upstreaming here: <https://github.com/NixOS/nixpkgs/pull/347323>
{
  buildLua,
  fetchFromGitHub,
  lib,
  newScope,
  unstableGitUpdater,
}:
lib.makeScope newScope (self: with self; {
  mkScript = scriptName: buildLua {
    pname = scriptName;
    version = "0-unstable-2023-03-03";
    src = fetchFromGitHub {
      owner = "occivink";
      repo = "mpv-image-viewer";
      rev = "efc82147cba4809f22e9afae6ed7a41ad9794ffd";
      hash = "sha256-H7uBwrIb5uNEr3m+rHED/hO2CHypGu7hbcRpC30am2Q=";
    };
    sourceRoot = "source/scripts";

    passthru = {
      updateScript = unstableGitUpdater { };
    };

    meta = {
      description = "configuration, scripts and tips for using mpv as an image viewer";
      homepage = "https://github.com/occivink/mpv-image-viewer";
      license = with lib.licenses; [ unlicense ];
      maintainers = with lib.maintainers; [ colinsane ];
    };
  };

  detect-image = mkScript "detect-image";
  equalizer = mkScript "equalizer";
  freeze-window = mkScript "freeze-window";
  image-positioning = mkScript "image-positioning";
  minimap = mkScript "minimap";
  ruler = mkScript "ruler";
  status-line = mkScript "status-line";
})
