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
  version = "0.1.3-unstable-2026-11-23";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "d1eb4fa146cc9a6ab08a636868bf1d830b327bd4";
    hash = "sha256-OthKDEs7meVsVSD2I53cJfm2GzwPWzc/3JCBCNLBzdc=";
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
