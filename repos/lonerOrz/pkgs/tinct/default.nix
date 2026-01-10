{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finallAttrs: {
  pname = "tinct";
  version = "0.1.0";

  # https://github.com/lonerOrz/tinct
  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "tinct";
    rev = "4152f2027e283bfa55d6fc38560a70c4deb2a4a0";
    hash = "sha256-dwS6V/rPV+YcFn7hNsxjPeyjv+n4cKaBgK3GtHyh5JM=";
  };

  cargoHash = "sha256-hAtURFMFLgLkyvtxix7gEhX2kIGqHnVAZar9C+jOeG0=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tinct";
  };
})
