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
  version = "0.11.32";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "astral-sh";
    repo = "uv";
    tag = finalAttrs.version;
    hash = "sha256-Vkh4GWcKpaAVrok7K/620jfaFayKZRCO32icfZ6+mSU=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-w8O655Ad9bz79KeWF00hniNX+fssY9ZE+LUKaWBQM7c=";
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
