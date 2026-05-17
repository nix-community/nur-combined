{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "wsl-open";
  version = "0-unstable-2026-05-17";

  # https://github.com/lonerOrz/wsl-open.git
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wsl-open";
    rev = "8d35053eb2b0ff3f06a3f94745180a219f796f33";
    hash = "sha256-+o0hHo3Mh48+WgcbhsFa4nit3n/gXFJnlJqUbNgoJEM=";
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
