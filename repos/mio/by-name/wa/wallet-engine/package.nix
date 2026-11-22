{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  python3,
  nix,
  git,
  coreutils,
  writeShellApplication,
}:

let
  version = "0.0.7-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "i582";
    repo = "wallet-engine";
    rev = "1d6f4a221afd09fbf5d66313cbc9fa1909e0bbbc";
    hash = "sha256-YIrUnrelDfEer2X+lLtJdYRKwTyELs0eqaoaSyFGmvg=";
  };

  bindgenCargoDeps = rustPlatform.fetchCargoVendor {
    pname = "wallet-engine-bindgen";
    inherit version src;
    cargoRoot = "bindgen/cpp";
    hash = "sha256-n3VKg3OMU9a4fbaxISWKEVXRe9vRe63/GeRdpmDEZTM=";
  };

  # Forkgram 7.3 looks up this exact checkout when DESKTOP_APP_USE_PACKAGED is set.
  engine = rustPlatform.buildRustPackage {
    pname = "wallet-engine";
    inherit version src;

    cargoHash = "sha256-b9LErZRUgVa/bHjmbN3ltW8vUoF9UhCjMAfFPSbpzbY=";

    cargoBuildFlags = [ "--lib" ];

    doCheck = false;

    postInstall = ''
      libext=${if stdenv.hostPlatform.isDarwin then "dylib" else "so"}
      # CMake find_library prefers the shared library. A second Rust staticlib
      # next to tlottie duplicates the Rust runtime and the link fails.
      rm -f "$out/lib/libwallet_engine.a"

      mkdir -p "$out/include/wallet_engine" "$TMPDIR/bindgen-home"

      export CARGO_HOME="$TMPDIR/bindgen-home"
      # The package .cargo/config.toml already replaces crates.io with the
      # library vendor. Point this command at the bindgen vendor instead.
      cargo run --offline --locked --release \
        --config "source.crates-io.replace-with='vendored-source-registry-0'" \
        --config "source.vendored-source-registry-0.directory='${bindgenCargoDeps}/source-registry-0'" \
        --manifest-path bindgen/cpp/bindgen/Cargo.toml -- \
        --library --out-dir "$out/include/wallet_engine" \
        "$out/lib/libwallet_engine.$libext"

      test -f "$out/include/wallet_engine/wallet_engine.hpp"
      test -f "$out/include/wallet_engine/wallet_engine.cpp"
    '';

    meta = {
      description = "TON wallet engine library used by Forkgram";
      homepage = "https://github.com/i582/wallet-engine";
      license = with lib.licenses; [
        mit
        asl20
      ];
      platforms = lib.platforms.unix;
    };
  };
in
stdenv.mkDerivation {
  pname = "wallet-engine";
  inherit version;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    cp -a ${engine} $out
    runHook postInstall
  '';
  passthru.updateScript = writeShellApplication {
    name = "update-wallet-engine";
    runtimeInputs = [
      python3
      nix
      git
      coreutils
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="wallet-engine"
      exec ${python3}/bin/python3 ${./update.py} "$@"
    '';
  };

  meta = engine.meta;
}
