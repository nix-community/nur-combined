{
  clangStdenv,
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  pname = "nixtopsy";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "nixtopsy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7sruBCkkco9xuDdlb9+wTr9/TuEXvIAm02M5q7lStIc=";
  };
  cargoHash = "sha256-Eub5UIGmQ/Co6zwHHea59xREZ3bliiOOqwZx1AKypPU=";

  env.RUSTFLAGS = "-Clinker=clang";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactively dissect your Nix closures";
    homepage = "https://github.com/manic-systems/nixtopsy";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "nixtopsy";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
