{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.9.30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-PDp7yktF2ek6KVlJvYsLn7VgV1ulgWnjAXKozJW3JKU=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-KoVAUbVheq/x5e7scqf8ZSyC0ZAXlcZJ7svuiuT7NzQ=";
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
