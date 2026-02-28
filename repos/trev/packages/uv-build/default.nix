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
  version = "0.10.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-W9RJh33G+gjuoPkYAZsc+CDmGzvXDH/0wOJFODfqWhc=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-zzscJBBF7h5vpeYM0ju2oo+ZlZ05aVF7oh9YppRuSZI=";
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
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Minimal build backend for uv";
    homepage = "https://docs.astral.sh/uv/reference/settings/#build-backend";
    inherit (uv.meta) changelog license;
    platforms = lib.platforms.all;
  };
})
