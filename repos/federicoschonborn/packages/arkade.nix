{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, wrapQtAppsHook
, kirigami2
, ki18n
, kpackage
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "arkade";
  version = "unstable-2023-07-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "games";
    repo = "arkade";
    rev = "a99558062dc5c4542671ae412752605b01f4ce0d";
    hash = "sha256-bACFeHmd10zM6E4wANVRf/IVo0ElbgExjy23yqOV9Kk=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    kirigami2
    ki18n
    kpackage
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };

  meta = with lib; {
    description = "Collection of Arcade games developed in Kirigami";
    homepage = "https://invent.kde.org/games/arkade";
    license = with licenses; [ bsd2 gpl3Plus ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
