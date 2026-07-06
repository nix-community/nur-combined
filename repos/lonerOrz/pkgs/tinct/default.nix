{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinct";
  version = "0.1.0-unstable-2026-07-06";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "2a00189ff8b896b3e6656143361318a71dcd4dd8";
    hash = "sha256-dm/2YdNlPCJx8cBkoJ+SIcttCqWRU4zDwgmPq16vY8w=";
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
