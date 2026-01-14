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
    rev = "61b1b9d7d93a94c4f8559d3d16c26e5fa1df38e1";
    hash = "sha256-c+mEHU1rxEpjXMkWtMyp84FBJZklYskGVPWG9NH5mDQ=";
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
