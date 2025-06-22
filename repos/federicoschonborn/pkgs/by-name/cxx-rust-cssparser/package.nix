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
  version = "0-unstable-2025-06-20";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "libraries";
    repo = "cxx-rust-cssparser";
    rev = "7293488a043caa70811d8308c678dd6a7e620de8";
    hash = "sha256-ZoVkL7umjoWzgX/nRK0W4qY3+usdxBrw23toB40zQQg=";
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
