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
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-QUAa+Ye7bczB2MGJraNpaK/h5fc94+IqwK91K/3ch7E=";
  };

  cargoHash = "sha256-0Hgg8ijcxA5OwnApW+pww1C+2haKsfpnesS5auJmTX0=";

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
