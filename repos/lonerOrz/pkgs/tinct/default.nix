{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinct";
  version = "0.2.0-unstable-2026-09-25";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "ad57c1459a1211116df3eec98da2d4eb3162deb2";
    hash = "sha256-dC4xL+yAYpCM6nRk5tLfE0cX619V3LkIwcL3KCxUL/I=";
  };

  cargoHash = "sha256-hRZHzJWsyw4EkcjRJzdt5bVq5iRSjsm5lsbjryR9Oe8=";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    mainProgram = "tinct";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
