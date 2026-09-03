{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fitch-vizier";
  version = "0-unstable-2026-08-31";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "FundamentalComputing";
    repo = "FitchVIZIER";
    rev = "6e3d81f7e73ff88f2da36d340772d6fabe7bd434";
    hash = "sha256-2bpUbAYVzJyaXctiAek1GdVCklZBGbxr/oCPQHyoxVA=";
  };

  sourceRoot = "${finalAttrs.src.name}/cli";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;
    hash = "sha256-jdf5haLe/vxv86meNP2ViIoMUrsodV+Bfz9eNG1ZXhs=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fitch-style prover";
    homepage = "https://github.com/FundamentalComputing/FitchVIZIER";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "fitchv";
  };
})
