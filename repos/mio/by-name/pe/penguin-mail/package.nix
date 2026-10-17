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
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-+IlLbsUAO/vB/Pankb5NTUtzXczm0kEN19zcW0/ighw=";
  };

  cargoHash = "sha256-pdiBex/nJBMAeUR9ho6B5g61bnnelFkQkP0KfE69cfY=";

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
