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
  version = "7.0.0-beta-4";

  origin-src = fetchFromGitHub {
    owner = "KonghaYao";
    repo = "cn-font-split";
    rev = version;
    hash = "sha256-Nvw+JnhRnL0GCjEBu3VLtvmamsUJbX5iZaklKMFiwCI=";
  };

  npm-lock = ./package-lock.json;
  cargo-lock = ./Cargo.lock;

  packages-json = stdenvNoCC.mkDerivation rec {
    name = "cn-font-split-npm-package-json";
    src = origin-src;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -rv ${src}/crates/lang_unicodes/package.json $out/
      cp -rv ${npm-lock} $out/package-lock.json

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
      cp -r ${src}/* $out/
      cp -r ${npmDeps}/node_modules $out/
      cp ${cargo-lock} $out/Cargo.lock

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

  cargoHash = "sha256-1YEtUWdNOUSV0FjJlH6XGpoKDpkl3loJzK8aFQZn8sE=";

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
