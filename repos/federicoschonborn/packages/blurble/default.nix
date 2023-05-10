{ lib
, stdenv
, fetchFromGitLab
, blueprint-compiler
, desktop-file-utils
, gettext
, libadwaita
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "blurble";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Blurble";
    rev = "v${version}";
    hash = "sha256-wxj+wyD09ueU6p/6Tc7ISI/oLre41DhGVhjsACDsmpE=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  meta = with lib; {
    description = "Word guessing game";
    homepage = "https://gitlab.gnome.org/World/Blurble";
    license = licenses.gpl3Only;
  };
}
