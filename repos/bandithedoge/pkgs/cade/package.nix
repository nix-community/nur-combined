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
  version = "0.1.3-unstable-2026-10-09";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "21c2c4186b42906e7584a29f7a17fdcfda7220be";
    hash = "sha256-7ZBsJljIPTFfXdLjkMJoKtnPq3L0eOS/suou37wE0Bo=";
  };

  cargoHash = "sha256-pnKpa5y9s/wazRm1wm2DOriaiu8pwNeZoJZJMqUMXSc=";

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
