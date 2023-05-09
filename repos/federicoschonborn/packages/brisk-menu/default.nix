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

stdenv.mkDerivation rec {
  pname = "brisk-menu";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "getsolus";
    repo = pname;
    rev = "v${version}";
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

  meta = with lib; {
    description = "An efficient menu for the MATE Desktop";
    homepage = "https://github.com/getsolus/brisk-menu";
    license = with licenses; [ gpl2Only cc-by-sa-40 ];
  };
}
