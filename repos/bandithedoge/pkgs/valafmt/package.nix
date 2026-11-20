{
  lib,
  nix-update-script,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "valafmt";
  version = "0-unstable-2026-11-08";
  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "valafmt";
    rev = "36903e1b730c44dd535393e5d80e12bf5ad9a60f";
    hash = "sha256-k9QIFJ1Em97sOVXfNn7Tx+lUdxWdaotkCVOLWAb7NEc=";
  };

  cargoHash = "sha256-UyHIGs55AZoTOe+mp+YKKyew9nblgXifPBbU/pfesLA=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Opinionated code formatter for Vala";
    homepage = "https://github.com/Aylur/valafmt";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "valafmt";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
