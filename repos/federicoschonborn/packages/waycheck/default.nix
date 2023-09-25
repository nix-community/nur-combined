{ lib
, gcc13Stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapQtAppsHook
, qtwayland
, wayland
}:

gcc13Stdenv.mkDerivation {
  pname = "waycheck";
  version = "unstable-2023-09-24";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "serebit";
    repo = "waycheck";
    rev = "bc601b4c44ce6e5c51fe82c5541c199cd7aad65d";
    hash = "sha256-WjDoL/pOse5hf5AaJCpkfDTPCq6QY0bOLo3/jlHJnFU=";
  };

  nativeBuildInputs = [
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
}
