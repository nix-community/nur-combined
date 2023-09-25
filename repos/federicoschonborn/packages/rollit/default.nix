{ lib
, stdenv
, fetchFromGitLab
, cargo
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, pango
}:

stdenv.mkDerivation rec {
  pname = "rollit";
  version = "3.3.0";

  src = fetchFromGitLab {
    owner = "zelikos";
    repo = "rollit";
    rev = version;
    hash = "sha256-v8G/XJGq1uOLBBVsnCW3alFy06xQVDWZxOj1hjYgR10=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-rUnDSifW8ZCys91wk0WTg3x+APjwhANtuVTloUfzl+k=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    pango
  ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.com/zelikos/rollit";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
