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
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rollit";
  version = "3.3.0";

  src = fetchFromGitLab {
    owner = "zelikos";
    repo = "rollit";
    rev = finalAttrs.version;
    hash = "sha256-v8G/XJGq1uOLBBVsnCW3alFy06xQVDWZxOj1hjYgR10=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "";
    homepage = "https://gitlab.com/zelikos/rollit";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder libadwaita.version "1.4";
  };
})
