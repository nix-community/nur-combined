{
  stdenvNoCC,
  lib,
  buildNpmPackage,
  rustPlatform,
  fetchFromGitHub,
  nodejs,
  protobuf,
  fetchNpmDeps,
}:
let
  version = "7.0.0-beta-2";

  origin-src = fetchFromGitHub {
    owner = "KonghaYao";
    repo = "cn-font-split";
    rev = version;
    hash = "sha256-dxHAJkWJbYBEcG9oE29hZZ5OPJc3ndHjmwpRKk0CF8c=";
  };

  package-lock = ./package-lock.json;

  packages-json = stdenvNoCC.mkDerivation rec {
    name = "cn-font-split-npm-package-json";
    src = origin-src;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -rv ${src}/packages/subsets-rs/crates/lang_unicodes/package.json $out/
      cp -rv ${package-lock} $out/package-lock.json

      runHook postInstall
    '';
  };

  npmDeps = buildNpmPackage {
    pname = "cn-font-split-node-modules";
    inherit version;
    src = packages-json;

    dontBuild = true;

    npmDeps = fetchNpmDeps {
      src = packages-json;
      hash = "sha256-+dwYY4OUahT6jSscmaUzq++PdJhF3RtOo+9A5Pyrozk=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/

      runHook postInstall
    '';
  };

  src = stdenvNoCC.mkDerivation rec {
    name = "cn-font-split-src";
    src = origin-src;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ${src}/packages/subsets-rs/* $out/

      # For cargo test
      cp -r ${src}/packages/demo $out/
      shopt -s globstar
      substituteInPlace $out/src/**/*.rs --replace '../demo' './demo'

      cp -r ${npmDeps}/node_modules $out/

      runHook postInstall
    '';
  };

in
rustPlatform.buildRustPackage {
  pname = "cn-font-split";
  inherit src version;

  nativeBuildInputs = [
    nodejs
    protobuf
  ];

  cargoHash = "sha256-ICvQIRQvNS2umJpmNUzCohr59mCuLoaujxy21CIYdt4=";

  meta = {
    description = "A revolutionary font subetter that supports CJK and any characters!";
    longDescription = ''
      A revolutionary font subetter that supports CJK and any characters! It enables multi-threaded subset of otf, ttf, and woff2 fonts, allowing for precise control over package size.
    '';
    homepage = "https://github.com/KonghaYao/cn-font-split";
    maintainers = with lib.maintainers; [
      Cryolitia
    ];
    mainProgram = "cn-font-split";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
