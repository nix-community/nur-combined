{
  cmake,
  fetchFromGitHub,
  fetchurl,
  lib,
  pkg-config,
  python3Packages,
  rustPlatform,
  stdenv,
}:

let
  version = "1.0.0";

  rustyV8Hashes = {
    "x86_64-linux" = "sha256-9IdiyhDR8fxgWkQcWuQw7Izh6egPFNePvELLh4wwtHY=";
    "aarch64-linux" = "sha256-U54oOBWjlqV5bzKFi0LlF7hY66rqqtBdAykO6MhkpSc=";
  };

  rustyV8BindingHashes = {
    "x86_64-linux" = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
    "aarch64-linux" = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
  };

  swaggerUi = fetchurl {
    url = "https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip";
    hash = "sha256-SBJE0IEgl7Efuu73n3HZQrFxYX+cn5UU5jrL4T5xzNw=";
  };

  # v8 crate >= 150 is built with the simdutf feature (deno_core enables it),
  # so the prebuilt archive must be the simdutf variant.
  rustyV8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v150.4.0/librusty_v8_simdutf_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash =
      rustyV8Hashes.${stdenv.hostPlatform.system}
        or (throw "pctx: unsupported platform ${stdenv.hostPlatform.system}");
  };

  rustyV8Binding = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v150.4.0/src_binding_release_${stdenv.hostPlatform.rust.rustcTarget}.rs";
    hash =
      rustyV8BindingHashes.${stdenv.hostPlatform.system}
        or (throw "pctx: unsupported platform ${stdenv.hostPlatform.system}");
  };

  py = python3Packages.callPackage ./python.nix { };
in
rustPlatform.buildRustPackage {
  pname = "pctx";
  inherit version;

  src = fetchFromGitHub {
    owner = "portofcontext";
    repo = "pctx";
    rev = "v${version}";
    hash = "sha256-5HmUd650cWG6aPyLEIaFQzumxVtCPEgoUWdp6IDwTR0=";
  };

  cargoHash = "sha256-zjlvVJZbu9YYMpnYfcmksqLmi4KmI+Nqqql8bdzdj6k=";
  cargoBuildFlags = [
    "-p"
    "pctx"
  ];
  doCheck = false;
  RUSTY_V8_ARCHIVE = "${rustyV8}";
  SWAGGER_UI_DOWNLOAD_URL = "file://${swaggerUi}";
  RUSTY_V8_SRC_BINDING_PATH = "${rustyV8Binding}";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  # nixpkgs' cargoSetup hook forces system libraries for every
  # buildRustPackage build (`cargoUseSystemLibs`: ZSTD_SYS_USE_PKG_CONFIG=1,
  # AWS_LC_SYS_USE_SYSTEM=1, a JEMALLOC_OVERRIDE pointing at a sentinel path
  # that does not exist, ...). pctx's transitive zstd-sys, aws-lc-sys and
  # tikv-jemalloc-sys then fail instead of building their bundled C sources,
  # and `crateOverrides` cannot supply them because a real-cargo build never
  # builds those crates individually. Keep the previous hermetic behaviour.
  dontCargoUseSystemLibs = true;

  passthru = { inherit py; };

  meta = with lib; {
    description = "The open source framework to connect AI agents to tools and mcp with Code Mode";
    homepage = "https://github.com/portofcontext/pctx";
    license = licenses.mit;
    mainProgram = "pctx";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
}
