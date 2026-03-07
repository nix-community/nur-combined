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
    rev = "44689c430599975034a9eecfd2a9c37bb8a1816d";
    hash = "sha256-XrcFU7JtlPUPZ1FtaEywGU53Qc3xePjrauf6TLnp9os=";
  };

  cargoHash = "sha256-MslAFqteq4Aa0gs88C+v//dQC2LtQsqkN9VbmeV+4Qw=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tinct";
  };
})
