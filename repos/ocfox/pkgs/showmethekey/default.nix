{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, libevdev
, json-glib
, cairo
, libinput
, gtk4
, wrapGAppsHook
, libxkbcommon
, pkg-config
}:
stdenv.mkDerivation rec {
  pname = "showmethekey";
  version = "04b04e468101d3bfa08a24f5dde9fb1c6cf27a22";

  src = fetchFromGitHub {
    owner = "AlynxZhou";
    repo = pname;
    rev = version;
    hash = "sha256-pfqlfAUl7a3xvH5HuTvb2csViYqGPv170XY0xlNRn1w=";
  };

  nativeBuildInputs = [
    meson
    ninja
    json-glib
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtk4
    cairo
    libevdev
    libinput
    libxkbcommon
  ];

}
