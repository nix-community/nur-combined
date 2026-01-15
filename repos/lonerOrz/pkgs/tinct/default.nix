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
    rev = "7063a4eaa51beb5ef2a36450d6994de76a084406";
    hash = "sha256-UKUw4zYIjBP24Ew05Qs1wTM8ZTfZ81V9KIjYB1kX6a8=";
  };

  cargoHash = "sha256-b/QJZmXJ8jmv/Mkxj8HGHXJc9olxKz3LX3uMKsga4NA=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tinct";
  };
})
