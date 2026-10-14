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
  version = "0.1.3-unstable-2026-10-14";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "8f6968724afe45f33ac8ba09f9c0262e5ebb31f8";
    hash = "sha256-/TOFSsj1bScy1zHEtx0l0J/dzu1pw2RDAC5Fcj4AFZY=";
  };

  cargoHash = "sha256-LHjJ5DkvFlIDWebJj8uIkrYKVCzxT/f9mswAz391DEs=";

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
