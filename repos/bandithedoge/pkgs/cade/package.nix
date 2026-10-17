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
  version = "0.1.3-unstable-2026-10-15";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "79ec54820642a067ada27a8765a6858c8c2a50e4";
    hash = "sha256-fE2LYUyCtR+7a5u7RMNpHzvefjNKykkJEchmJ22aC5E=";
  };

  cargoHash = "sha256-L16kfpP7xnlBcewAhfAlCGeotALKIF+7Bbew8bnKM/8=";

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
