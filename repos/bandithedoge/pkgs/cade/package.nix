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
  version = "0.1.0-unstable-2026-08-15";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "d119b4f3d1199209f571b7bfdeebc0cf20c04ae6";
    hash = "sha256-7PKZV/3rH0SYioQUBWBVE2f4pJoqe4hbyrSLFRaH/e8=";
  };

  cargoHash = "sha256-xcUCJ2ZtxpUu1MIoWV8yVWXsDQY/UAWkZCBy+beCdWQ=";

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
