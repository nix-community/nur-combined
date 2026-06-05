{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
  wayland,
  wayland-protocols,
  libepoxy,
  pkgconf,
  aeroshell-smod,
}:

stdenv.mkDerivation rec {
  pname = "aeroshell-smodglow";
  version = "0";

  src = aeroshell-smod.src;

  sourceRoot = "source/smodglow";

  dontWrapQtApps = true;

  buildInputs = aeroshell-smod.buildInputs ++ [ aeroshell-smod ];

  nativeBuildInputs = aeroshell-smod.nativeBuildInputs;

  cmakeFlakgs = [
    (lib.cmakeFeature "KWIN_BUILD_WAYLAND" "ON")
    (lib.cmakeFeature "BUILD_TESTING" "OFF")
  ];

  meta = with lib; {
    license = licenses.agpl3Plus;
    description = "Decoration button glow effect for SMOD decorations";
    homepage = "https://github.com/aeroshell-desktop/smod";
    platforms = platforms.unix;
  };
}
