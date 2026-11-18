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
  version = "0.1.3-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "ae2aa77f9442209261535c4ee53a67e946ca482d";
    hash = "sha256-aaqCFYAXcq59Cl5yo73ERoJqOHDdPqvO2Qfg307hyuc=";
  };

  cargoHash = "sha256-Bothg9eAegpEWm9VT6s8Nmp6bya9WSVUsnoLRI5Q8m0=";

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
