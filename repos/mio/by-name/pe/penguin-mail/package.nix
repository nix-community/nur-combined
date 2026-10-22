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
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-TmlAejbQKABTpCaQ0kTDvTan22Da215vIFfKuxlgqUw=";
  };

  cargoHash = "sha256-wyT97HUXlqjcrNji08ioFPu6GnPRz8PMaoyOE86XHbg=";

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
