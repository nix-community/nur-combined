{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinct";
  version = "0.1.2-unstable-2026-09-07";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "a5469570706b9ead1ad6c3892ce1f81d6c726290";
    hash = "sha256-ChiLCqZA4497naNhXdUpV8qEmwOR77mA+CdVRzHSViA=";
  };

  cargoHash = "sha256-ExuKv+RUIqIxEhxV/083poPZOa2q7deYQ5IeyiRtKhk=";

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    mainProgram = "tinct";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
