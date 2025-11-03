{
  lib,
  rustPlatform,
  maa-cli',
  fetchFromGitHub,
  stdenv,
  fetchurl,
}:
let
  sources = lib.importJSON ./pin.json;
in
rustPlatform.buildRustPackage {
  pname = "maa-cli";
  version = sources.maa-cli.name;

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "${sources.maa-cli.version}";
    hash = sources.maa-cli.hash;
  };

  nativeBuildInputs = maa-cli'.nativeBuildInputs;

  buildInputs = maa-cli'.buildInputs;

  buildNoDefaultFeatures = maa-cli'.buildNoDefaultFeatures;
  buildFeatures = maa-cli'.buildFeatures;

  SKIP_CORE_TEST = 1;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postInstall = maa-cli'.postInstall;

  passthru.updateScript = ./update.sh;

  meta = maa-cli'.meta // {
    broken = true;
  };
}
