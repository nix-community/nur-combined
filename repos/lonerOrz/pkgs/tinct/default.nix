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
    rev = "ca8b0ecf704fc8d48685c5ba7cf1b53429af5ff8";
    hash = "sha256-ER5rtUI3nA0i8bckpHi+JZ+ysOxSUWbfcYmBRQPwK98=";
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
