{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  cmake,
  ninja,
  rustc,
  kdePackages,
  rustPlatform,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cxx-rust-cssparser";
  version = "0-unstable-2025-06-25";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "libraries";
    repo = "cxx-rust-cssparser";
    rev = "25f9d3b46ae585ddae9b230db2d7f0a0350046a0";
    hash = "sha256-fxbXkU5KyAFCW339xsMt262ggypeOSI6z0cIDPNOHJQ=";
  };

  nativeBuildInputs = [
    cargo
    cmake
    ninja
    rustc
    kdePackages.extra-cmake-modules
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    kdePackages.qtbase
  ];

  cargoRoot = "rust";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;
    hash = "sha256-Ju3QyTCMfCfXo39AlPbKem4Kzm3zj0nH6jymlnzPnrY=";
  };

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "cxx-rust-cssparser";
    description = "Library for parsing CSS using the Rust cssparser crate";
    homepage = "https://invent.kde.org/libraries/cxx-rust-cssparser";
    license = with lib.licenses; [
      bsd2
      cc0
      lgpl21Only
      lgpl3Only
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
