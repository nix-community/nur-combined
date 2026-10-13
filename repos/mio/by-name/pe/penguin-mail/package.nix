{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  openssl,
  gtk4,
  glib,
  webkitgtk_6_0,
  libadwaita,
}:

rustPlatform.buildRustPackage rec {
  pname = "penguin-mail";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-AHu9CRRouoLA9Gd/kRf6Wg7/KwG+PhOT3MD4F2N9QXQ=";
  };

  cargoHash = "sha256-ZuowxHI22IfLeKzy6rIZNxl+6edQNaCi4iEj95uif/A=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
    gtk4
    glib
    webkitgtk_6_0
    libadwaita
  ];

  doCheck = false;

  meta = with lib; {
    description = "Penguin Mail";
    homepage = "https://github.com/c9dev/penguin-mail";
    license = licenses.gpl3Only; # Need to verify exact license
    maintainers = [ ];
    mainProgram = "penguin-mail";
  };
}
