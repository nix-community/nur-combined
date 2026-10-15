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
    rev = "250ef2c417ae78ca54decba9305bea3ed9686ca0";
    hash = "sha256-Fe5OWyg7F7iGDWBW0N8N246Echby6P3/9xF4283t3Z4=";
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
