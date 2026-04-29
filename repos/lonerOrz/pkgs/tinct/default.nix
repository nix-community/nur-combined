{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinct";
  version = "0-unstable-2026-04-03";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "bd0bfaa8c5d541cb3be36b7d141226ecd967989a";
    hash = "sha256-6D+ZFD9l5GULUujeuQFhEkYDUsVkuhMjoeNMKTuZApQ=";
  };

  cargoHash = "sha256-7lNzZ8gMcYOsWVEVwdFnFINYZv08oeNh0HxdzyarUVA=";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    mainProgram = "tinct";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
