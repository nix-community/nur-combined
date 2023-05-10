{ lib
, stdenv
, fetchFromGitLab
, blueprint-compiler
, meson
, ninja
, pkg-config
, rustPlatform
, cairo
, gdk-pixbuf
, glib
, gtk4
, libadwaita
, libsecret
, pango
, tracker
, darwin
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "health";
  version = "0.94.0";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Health";
    rev = version;
    hash = "sha256-KS0sdCQg2LqQB0K1cUbAjA8VITn5rAb8XCWjOKYbPqM=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-0zX0AtnE1PaxWt4yZWlesUe+x/yLz+0fDpsQXIexS+M=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gtk4
    libadwaita
    libsecret
    pango
    tracker
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Track your fitness goals.\r\n\r\nSee https://world.pages.gitlab.gnome.org/Health/libhealth/index.html for documentation\r\n\r\nChat with us: https://matrix.to/#/!kZVunSLsOSBXOdzKwz:gnome.org?via=gnome.org";
    homepage = "https://gitlab.gnome.org/World/Health";
    license = licenses.gpl3Only;
    # TODO: Needs data/ui/setup_window.blp:296 to be fixed.
    broken = true;
  };
}
