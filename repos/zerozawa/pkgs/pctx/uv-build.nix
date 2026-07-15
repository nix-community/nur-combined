{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.9.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-KhJN9aYWeeo3Hc7pprNkzTZS2xsogdJmK5rDKlcjWp4=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-IZ168ImtJ4iBz23KOZzY27urHpj+PexE8IGco0Kd1eg=";
  };

  buildAndTestSubdir = "crates/uv-build";
  maturinBuildProfile = "minimal-size";
  pythonImportsCheck = [ "uv_build" ];
  doCheck = false;

  meta = with lib; {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/";
    license = with licenses; [
      mit
      asl20
    ];
  };
})
