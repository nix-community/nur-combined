# FIXME error: failed to get `anyhow` as a dependency of package `build_pluggables`

# based on https://github.com/NixOS/nixpkgs/pull/476510

# based on
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md
# Compiling non-Rust packages that include Rust code

{
  lib,
  callPackage,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  qt5,
  openssl,
  protobuf,
  pkg-config,
  cmake,
  cargo,
  rustc,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "ricochet-refresh";
  version = "3.0.40-2473de0";

  src = fetchFromGitHub {
    owner = "blueprint-freespeech";
    repo = "ricochet-refresh";
    # tag = "v${finalAttrs.version}-release";
    rev = "2473de0794b8e6db570dc349319791e6dca8c55c";
    fetchSubmodules = true;
    hash = "sha256-1om2KGSIB5BLhCiXOH4J5/sEfbHNANryknh8b7h+QuA=";
  };

  # libtego_rs is built in a separate derivation because it has a separate Cargo.lock file
  libtego_rs = rustPlatform.buildRustPackage (finalAttrs_libtego: rec {
    pname = "ricochet-refresh-libtego_rs";
    inherit (finalAttrs) version src meta;
    # fix: crates/tego-rs/build.rs: CARGO_TARGET_DIR not set
    CARGO_TARGET_DIR = "target";
    cargoHash = "sha256-6K8IhE/z+Y2Wu5skHNsscof2qXLoJ6SflBqNFNy4vWA=";
    sourceRoot = "${finalAttrs_libtego.src.name or finalAttrs.pname}/src/libtego_rs";
    doCheck = false;

    # ricochet-refresh/src/libtego_rs/crates/tego-rs/CMakeLists.txt
    # file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/include/tego/tego.hpp ${tego_rs_include_dir}/tego/tego.hpp)
    postInstall = ''
      mkdir -p $out/include/tego
      cp -v crates/tego-rs/include/tego/* $out/include/tego
      cp -v crates/tego-rs/target/release/include/tego/* $out/include/tego
    '';
  });

  passthru = {
    inherit libtego_rs;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src sourceRoot cargoRoot;
    hash = "sha256-tSOmvbm1POi+AUahxePI5YqxQZ/v4Wv2S5flCyOm1zw=";
  };

  sourceRoot = "${finalAttrs.src.name or pname}/src";

  # relative to sourceRoot
  cargoRoot = "ricochet-refresh-qt";
  cargoVendorDir = "ricochet-refresh-qt";

  postPatch = ''
    grep -r -l -F 'define TEGO_VERSION_STR "devbuild"' |
    while read f; do
      echo "patching TEGO_VERSION_STR in $f"
      substituteInPlace "$f" \
        --replace-fail \
          'define TEGO_VERSION_STR "devbuild"' \
          'define TEGO_VERSION_STR "${version}"'
    done
  '';

  strictDeps = true;

  preBuild = ''
    # fix: error: failed to get `anyhow` as a dependency of package `build_pluggables`
    export CARGO_HOME=/build/.cargo

    # add tego/tego.hpp
    cp -r ${libtego_rs}/include/tego ricochet-refresh-qt
  '';

  buildInputs =
    (with qt5; [
      qtbase
      qttools
      qtmultimedia
      qtquickcontrols2
      qtwayland
    ])
    ++ [
      openssl
      protobuf
      libtego_rs
    ];

  nativeBuildInputs = [
    pkg-config
    protobuf
    cmake
    qt5.wrapQtAppsHook
    qt5.qttools

    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  enableParallelBuilding = true;

  cmakeBuildType = "MinSizeRel";

  # https://github.com/blueprint-freespeech/ricochet-refresh/blob/main/BUILDING.md
  cmakeFlags = [
    (lib.cmakeBool "RICOCHET_REFRESH_INSTALL_DESKTOP" true)
    (lib.cmakeBool "USE_SUBMODULE_FMT" true)
    (lib.cmakeBool "BUILD_QT_FRONTEND" true)
  ];

  meta = {
    description = "Secure chat without DNS or WebPKI";
    mainProgram = "ricochet-refresh";
    longDescription = ''
      Ricochet Refresh is a peer-to-peer messenger app that uses Tor
      to connect clients.

      When you start Ricochet Refresh it creates a Tor hidden
      service on your computer.  The address of this hidden service
      is your anonymous identity on the Tor network and how others
      will be able to communicate with you.  When you start a chat
      with one of your contacts a Tor circuit is created between
      your machine and the your contact's machine.

      The original Ricochet uses onion "v2" hashed-RSA addresses,
      which are no longer supported by the Tor network.  Ricochet
      Refresh upgrades the original Ricochet protocol to use the
      current onion "v3" ed25519 addresses.
    '';
    homepage = "https://www.ricochetrefresh.net/";
    downloadPage = "https://github.com/blueprint-freespeech/ricochet-refresh/releases";
    # actually unfree
    # https://github.com/blueprint-freespeech/ricochet-refresh/issues/153
    # https://github.com/blueprint-freespeech/ricochet-refresh/commit/b0a274c07f0e8afd7b6727e3fe8428e1f9ad5249
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
