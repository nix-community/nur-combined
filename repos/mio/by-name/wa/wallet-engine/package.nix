{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  python3,
  nix,
  git,
  coreutils,
  writeShellApplication,
}:

let
  # Forkgram 7.4.6 builds this engine from its own pinned commit plus the patch
  # set from desktop-app/patches; see .github/workflows/mac_packaged.yml there.
  version = "0.0.7-unstable-2026-10-02";
  src = fetchFromGitHub {
    owner = "i582";
    repo = "wallet-engine";
    rev = "e59e0d89d7ee90c388bf36e3334c5b276f396697";
    hash = "sha256-729W7YCjkUCdL8Xk8BPHKdjpK6F+x1C9wnk/17TGhx4=";
  };

  # Forkgram's own patch for this engine comes from the shared
  # desktop-app/patches repo, at the commit its mac_packaged workflow pins
  # next to WALLET_ENGINE. Fetch it rather than vendoring the ~12k-line delta.
  rustPatchesRev = "8a28b8433af70771c3d101c776ad837a94bd47ec";
  rustPatches = fetchurl {
    url = "https://raw.githubusercontent.com/desktop-app/patches/${rustPatchesRev}/wallet-engine.patch";
    hash = "sha256-R9zeNHfgVt6GuhPIz1Xq30sTCdDpBLvgarBZLw++LP4=";
  };

  bindgenCargoDeps = rustPlatform.fetchCargoVendor {
    pname = "wallet-engine-bindgen";
    inherit version src;
    cargoRoot = "bindgen/cpp";
    hash = "sha256-n3VKg3OMU9a4fbaxISWKEVXRe9vRe63/GeRdpmDEZTM=";
  };

  # Forkgram looks up this exact checkout when DESKTOP_APP_USE_PACKAGED is set.
  engine = rustPlatform.buildRustPackage {
    pname = "wallet-engine";
    inherit version src;

    cargoHash = "sha256-b9LErZRUgVa/bHjmbN3ltW8vUoF9UhCjMAfFPSbpzbY=";

    # Forkgram builds this engine from a pinned commit plus its own patch set.
    patches = [ rustPatches ];

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
