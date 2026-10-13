{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

let
  version = "0.0.7-unstable-2026-10-13";
  src = fetchFromGitHub {
    owner = "i582";
    repo = "wallet-engine";
    rev = "e59e0d89d7ee90c388bf36e3334c5b276f396697";
    hash = "sha256-729W7YCjkUCdL8Xk8BPHKdjpK6F+x1C9wnk/17TGhx4=";
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

    patches = [ ./decode-sign-data-cell.patch ];

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
# uniffi-bindgen-cpp keeps a leading `_` on the C++ parameter and drops it in
# the call, so the generated `_schema` / `_cell` method does not compile.
stdenv.mkDerivation {
  pname = "wallet-engine";
  inherit version;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    cp -a ${engine} $out
    chmod u+w $out/include/wallet_engine $out/include/wallet_engine/wallet_engine.cpp
    substituteInPlace $out/include/wallet_engine/wallet_engine.cpp \
      --replace-fail 'FfiConverterString::lower(schema)' 'FfiConverterString::lower(_schema)' \
      --replace-fail 'FfiConverterString::lower(cell)' 'FfiConverterString::lower(_cell)'
    runHook postInstall
  '';
  meta = engine.meta;
}
