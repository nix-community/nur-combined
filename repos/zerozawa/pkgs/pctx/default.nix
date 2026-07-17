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
  version = "0.7.2";

  rustyV8Hashes = {
    "x86_64-linux" = "sha256-chV1PAx40UH3Ute5k3lLrgfhih39Rm3KqE+mTna6ysE=";
    "aarch64-linux" = "sha256-4IivYskhUSsMLZY97+g23UtUYh4p5jk7CzhMbMyqXyY=";
  };

  rustyV8BindingHashes = {
    "x86_64-linux" = "sha256-Rzab+z7pp+bg9FGuICQlldWn8LOvzAuUR+T5n/F0aGo=";
    "aarch64-linux" = "sha256-Rzab+z7pp+bg9FGuICQlldWn8LOvzAuUR+T5n/F0aGo=";
  };

  swaggerUi = fetchurl {
    url = "https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip";
    hash = "sha256-SBJE0IEgl7Efuu73n3HZQrFxYX+cn5UU5jrL4T5xzNw=";
  };

  rustyV8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash =
      rustyV8Hashes.${stdenv.hostPlatform.system}
        or (throw "pctx: unsupported platform ${stdenv.hostPlatform.system}");
  };

  rustyV8Binding = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v145.0.0/src_binding_release_${stdenv.hostPlatform.rust.rustcTarget}.rs";
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
    hash = "sha256-WTOxAL9XvVjg4M2jeMZjAtvBkRG/acrn8FrlZDsiy1Q=";
  };

  cargoHash = "sha256-ImbVGvwRYV9E54r92FiQ8eGFz8AetMCWE/TQ1lk5IAU=";
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

  passthru = { inherit py; };

  meta = with lib; {
    description = "Execution layer for agentic tool calls and MCP servers";
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
