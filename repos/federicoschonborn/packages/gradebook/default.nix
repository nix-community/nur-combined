{ lib
, stdenv
, fetchFromGitHub
, gtk4
, json-glib
, libadwaita
, meson
, ninja
, pkg-config
, vala
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "gradebook";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "leolost2605";
    repo = "Gradebook";
    rev = "v${version}";
    hash = "sha256-ZCBaQLU3323t+OAi7NfFNDgJqMfPEw7zoEkma3TX93g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    json-glib
    libadwaita
  ];

  meta = with lib; {
    description = "Grades tracker for pupils and students";
    homepage = "https://github.com/leolost2605/Gradebook";
    mainProgram = "io.github.leolost2605.gradebook";
    license = licenses.gpl3Only;
  };
}
