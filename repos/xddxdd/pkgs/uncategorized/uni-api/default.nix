{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  zstd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-17";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "a7bcebdf6f17f80318916cf99f7e92347da641aa";
    hash = "sha256-Ymvz2uranHzBXg3ZbOpKtPRxZyix0puiOn1dgAJRH2E=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-3n/9xao0u4uldMuc8kI3j1bOtKSgsO7eWbLqt0MHhhY=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    sqlite
    zstd
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
