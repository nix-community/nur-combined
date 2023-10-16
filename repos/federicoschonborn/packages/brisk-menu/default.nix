{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, gtk3
, libnotify
, mate
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brisk-menu";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "getsolus";
    repo = "brisk-menu";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-e7ETdVv0/9UFyfLFQiZalxCEiVaOWYq+0Cv3BTvYecU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk3
    libnotify
    mate.mate-panel
    mate.mate-menus
  ];

  meta = {
    description = "An efficient menu for the MATE Desktop";
    homepage = "https://github.com/getsolus/brisk-menu";
    license = with lib.licenses; [ gpl2Only cc-by-sa-40 ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
