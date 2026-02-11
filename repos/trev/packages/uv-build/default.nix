{
  lib,
  pkgs,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
  nix-update-script,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "uv-build";
  version = "0.10.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-7huzemS9BLCOmfzr2cSd8Tc4PtTJV0peYQ5FN2VaPKw=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-kSpRcliQpCCjpZUSCwd9THszOSmdXDIooJA4ZPtRjvo=";
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
      "${finalAttrs.pname}"
    ];
  };

  meta = {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    inherit (pkgs.uv.meta) changelog license;
    platforms = lib.platforms.all;
  };
})
