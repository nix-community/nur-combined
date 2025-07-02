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
  version = "0-unstable-2025-07-01";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "libraries";
    repo = "cxx-rust-cssparser";
    rev = "fa1802a63401c6e44f106a75654f18d67642e0b6";
    hash = "sha256-3wOlq+FIR2bAy0ajJF4lNmbNvcgKMQ+9i2T1HpGFm2o=";
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
