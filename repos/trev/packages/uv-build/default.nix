{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  uv,

  # python packages
  buildPythonPackage,
}:

buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.11.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-lhNGjMx9vL+G+chf0ASdw9nhdGQ20Y6RKtDVXCKR5Fc=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-CSkaJTl1a3C6u1SObsC/TBLH4weOPxmc99Tq6bwFJnE=";
  };

  buildAndTestSubdir = "crates/uv-build";

  # $src/.github/workflows/build-binaries.yml#L139
  maturinBuildProfile = "minimal-size";

  pythonImportsCheck = [ "uv_build" ];

  # The package has no tests
  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "${finalAttrs.pname}-latest"
    ];
  };

  meta = {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    inherit (uv.meta) changelog license;
    platforms = lib.platforms.all;
  };
})
