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
  version = "0.1.0-unstable-2026-09-09";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "3211f782a53f94842bbb8782de03a2c5d85c793d";
    hash = "sha256-Xrwc9hgghoOp2ySoBY1Mbyyi8mkR/HBHdFQ+5ATfikU=";
  };

  cargoHash = "sha256-Hpmge+YRDUhovt55NoBDd9GSV15cp184nDuMJZDnOX8=";

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
