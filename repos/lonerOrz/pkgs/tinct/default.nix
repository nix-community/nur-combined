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
    rev = "9b828d239371b8b6958b5338f16c022cfbeea3f0";
    hash = "sha256-w/CM7n21dtydyw9yAp/SkELVogHK+V0XTePYkV/gznw=";
  };

  cargoHash = "sha256-fN/CykGctlGmN2JfuIj5/KYOSuUbpxrNkU0ucvsWRM0=";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Theme injector tool that applies Material Design 3 color palettes to various configuration files";
    homepage = "https://github.com/lonerOrz/tinct";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tinct";
  };
})
