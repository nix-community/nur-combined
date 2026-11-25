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
  version = "0.1.3-unstable-2026-11-25";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "5781758070f2c6b7efa196bcab175f82800ac984";
    hash = "sha256-Ghl0l4uGXEUbyEehakR6BzThu8JXc+tVpTCqMrnzH4w=";
  };

  cargoHash = "sha256-/GIt3E7f3xeuWCDjRClakb4BvgPMY//YGP/RzS7j5Ok=";

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
