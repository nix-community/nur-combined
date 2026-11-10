{
  stdenv,
  rustPlatform,
  cargo,
  rustc,
  fetchFromForgejo,
  cmake,
  corrosion,
  perl,
  boost,
  catch2_3,
  olm,
  nix-update-script,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "vodozemac-bindings-kazv";
  version = "1.0.0-unstable-2026-11-09";
  src = fetchFromForgejo {
    domain = "r.lily-is.land";
    forceFetchGit = true;
    owner = "the-kazv-project";
    repo = "vodozemac-bindings";
    rev = "9026fdbb27efd27a390c3ab0ee8573ba35bc783d";
    hash = "sha256-h/VVmqAiFhxlb4MKdzedYNNuNxkiWQD/D5aYrk0t0sg=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    cmake
    corrosion
    perl
  ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck) ];

  doCheck = true;

  checkInputs = [
    boost
    catch2_3
    # libolm is only used as a reference implementation for interoperability tests.
    (olm.overrideAttrs (oldAttrs: {
      meta = oldAttrs.meta // {
        knownVulnerabilities = [ ];
      };
    }))
  ];

  postCheck = ''
    cargo test --manifest-path ../Cargo.toml --workspace --release --offline --locked
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^v(.*)$"
    ];
  };

  meta = {
    description = "Language bindings for vodozemac";
    homepage = "https://r.lily-is.land/the-kazv-project/vodozemac-bindings";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.linux;
  };
})
