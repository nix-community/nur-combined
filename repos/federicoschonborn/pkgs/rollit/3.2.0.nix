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

stdenv.mkDerivation (finalAttrs: {
  pname = "rollit";
  version = "3.2.0";

  src = fetchFromGitLab {
    owner = "zelikos";
    repo = "rollit";
    rev = finalAttrs.version;
    hash = "sha256-K8m+BbpRk+/UkiecPf6+qOFspiZJ3GmCxnbheTOkoTY=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-KJwCz1pGe8NN1PZ3jASJgnjQPBT7wNqTOAcwKx3Tpdo=";
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
})
