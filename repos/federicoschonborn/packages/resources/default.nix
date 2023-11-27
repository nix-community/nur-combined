{ lib
, stdenv
, fetchFromGitHub
, cargo
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustc
, rustPlatform
, wrapGAppsHook4
, libadwaita
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "resources";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "nokyan";
    repo = "resources";
    rev = "v${version}";
    hash = "sha256-OVz1vsmOtH/5sEuyl2BfDqG2/9D1HGtHA0FtPntKQT0=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-MNYKfvbLQPWm7MKS5zYGrc+aoC9WeU5FTftkCrogZg0=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  mesonFlags = [
    "-Dprofile=default"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    mainProgram = "resources";
    description = "Monitor your system resources and processes";
    homepage = "https://github.com/nokyan/resources";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}
