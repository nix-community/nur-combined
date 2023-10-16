{ lib
, stdenv
, fetchFromGitLab
, desktop-file-utils
, gtk3
, meson
, ninja
, pkg-config
, wrapQtAppsHook
, qtwayland
, wayland
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waycheck";
  version = "1.0.0";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "serebit";
    repo = "waycheck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oGpiFwbPBQHF0wRHliltU8B+QmClcoFfbjpAYzOFPqs=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gtk3 # for gtk-update-icon-cache
    meson
    ninja
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtwayland
    wayland
  ];

  meta = {
    description = "Simple GUI that displays the protocols implemented by a Wayland compositor";
    homepage = "https://gitlab.freedesktop.org/serebit/waycheck";
    platforms = lib.platforms.linux;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
