{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "wsl-open";
  version = "0.1.0-unstable-2026-05-17";

  # https://github.com/lonerOrz/wsl-open.git
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wsl-open";
    rev = "fadac078297ad6d33a05a05c298eddfcb6405d5c";
    hash = "sha256-UxP6S1cZORc0VPcbuJVCRa5UPHk1tjqW7osBBkexnVA=";
  };

  cargoHash = "sha256-DbFrj7Xdx9mQQj74kQf9vAfRNoGRozq+nwBR//NnT9Q=";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Open files, images, URLs, etc. from Windows with in WSL";
    homepage = "https://github.com/lonerOrz/wsl-open";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wsl-open";
  };
})
