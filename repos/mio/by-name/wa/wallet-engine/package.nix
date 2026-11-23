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
  version = "0.0.7-unstable-2026-11-23";
  src = fetchFromGitHub {
    owner = "i582";
    repo = "wallet-engine";
    rev = "88df18f89229e1dd6da624ada8fef66906211830";
    hash = "sha256-lvgwLLND9H8zBFl9Tg7w/d2Ow59zw+8xXQw7HbGEKds=";
  };

  bindgenCargoDeps = rustPlatform.fetchCargoVendor {
    pname = "wallet-engine-bindgen";
    inherit version src;
    cargoRoot = "bindgen/cpp";
    hash = "sha256-jM7V9TWzwwUU+Qnk0PBngR899utZmDxtj2wPL/TJa2Q=";
  };

  # Forkgram 7.3 looks up this exact checkout when DESKTOP_APP_USE_PACKAGED is set.
  engine = rustPlatform.buildRustPackage {
    pname = "wallet-engine";
    inherit version src;

    cargoHash = "sha256-oIchzPdsfjg0lGm5bcd61iYTOb0JVRiTUZMzCyjUdkc=";

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
  passthru = {
    # Exposed so update.py can resolve each vendor hash on its own. Building
    # the whole package resolves both fixed-output derivations in parallel and
    # only reports whichever one happened to fail first, which is the wrong
    # hash for the other one.
    inherit bindgenCargoDeps;
    inherit (engine) cargoDeps;
    updateScript = writeShellApplication {
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
  };

  meta = engine.meta;
}
