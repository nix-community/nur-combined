{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  pname = "cade";
  version = "0.1.3-unstable-2026-11-09";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "6dd6201bf42718b279bdedb086360b067247117e";
    hash = "sha256-EZ6fCReAiGerv3zMVgaOPyll2WZP606bPQ8J/t9/0SM=";
  };

  cargoHash = "sha256-sTazOZk9D3MKl7tdqqj9aomhRqFDpS46HK+UK6XSd/k=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Intelligent, cascading environment manager";
    homepage = "https://github.com/manic-systems/cade";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "cade";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
