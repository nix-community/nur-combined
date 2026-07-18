{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "wsl-open";
  version = "0.1.1-unstable-2026-07-18";

  # https://github.com/lonerOrz/wsl-open.git
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wsl-open";
    rev = "ef19c809c30b7f7df8491d30bf1d1066022df16b";
    hash = "sha256-Mt8wqxNx9Q+q7p05n6NZlGtMyN/lUHAYDaS4tZDycAg=";
  };

  cargoHash = "sha256-BsYwz7A6DIinoqNjKJkQZGM3M8hT3ir7xlO65VLcEAo=";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Open files, images, URLs, etc. from Windows with in WSL";
    homepage = "https://github.com/lonerOrz/wsl-open";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wsl-open";
  };
})
