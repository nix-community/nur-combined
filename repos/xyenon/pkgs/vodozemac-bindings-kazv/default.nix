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
  version = "1.0.0-unstable-2026-10-24";
  src = fetchFromForgejo {
    domain = "r.lily-is.land";
    forceFetchGit = true;
    owner = "the-kazv-project";
    repo = "vodozemac-bindings";
    rev = "5c9d82bb51c4babcbdb8a025dd1ffb82e475b3d6";
    hash = "sha256-qnMFJILhkrax++549AQ+HUHvZNYa/EZYKBBtId+XA0k=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "vodozemac-0.10.0" = "sha256-nAeQNGc7zIzickS4nCNTxUC+IkLI2J7JyfHXkTeylEg=";
    };
  };

  # Corrosion 0.6 places Cargo artifacts in a directory with a manifest path hash.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'COMMAND "''${CMAKE_COMMAND}" -E copy "''${CMAKE_BINARY_DIR}/cargo/build/''${Rust_CARGO_TARGET}/cxxbridge/vodozemac/src/lib.rs.h" "''${CMAKE_BINARY_DIR}/vodozemac.h"' \
        'COMMAND sh -c "cp ''${CMAKE_BINARY_DIR}/cargo/*/''${Rust_CARGO_TARGET}/cxxbridge/vodozemac/src/lib.rs.h ''${CMAKE_BINARY_DIR}/vodozemac.h"'
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
