{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinct";
  version = "0-unstable-2026-06-22";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "d562994be909351a7541ab6a82ba0b547a7348ce";
    hash = "sha256-OYKZ41VXiLP/ILIex5J4keXwAXCOn642pxee1Jpl8vs=";
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
