{ lib
, gcc13Stdenv
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

gcc13Stdenv.mkDerivation (finalAttrs: {
  pname = "waycheck";
  version = "0.2.0";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "serebit";
    repo = "waycheck";
    rev = "v${finalAttrs.version}";
    hash = "sha256-J1Jv/JroA81K4mExNmRQVpih2xh0so8fI/skhcAE/uE=";
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

  meta = with lib; {
    description = "Simple GUI that displays the protocols implemented by a Wayland compositor";
    homepage = "https://gitlab.freedesktop.org/serebit/waycheck";
    platforms = platforms.linux;
    license = licenses.asl20;
    maintainers = with maintainers; [ federicoschonborn ];
  };
})
