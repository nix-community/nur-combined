{ lib
, stdenv
, fetchFromGitHub
, cargo
, desktop-file-utils
, meson
, ninja
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
, libadwaita
, libxml2
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "game-of-life";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "sixpounder";
    repo = "game-of-life";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vKZAFyM805EE4IEXa15hvXLGTa0P09V5stvvzOt/svU=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-vQsLqT9PGHPyUjsTQnXTrXohulKTo3bC5Eqtm3jMajE=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    libxml2
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "game-of-life";
    description = "A Conway's Game Of Life application for the gnome desktop";
    homepage = "https://github.com/sixpounder/game-of-life";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
