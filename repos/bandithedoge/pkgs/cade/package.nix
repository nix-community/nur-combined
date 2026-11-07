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
  version = "0.1.3-unstable-2026-11-04";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "249ef691155259f0f345e80ed28390755f3d9be3";
    hash = "sha256-Uky5jpgAijchZhsYNtk67JlO3zPeZJnX3Hi4c92W8ko=";
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
