{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-yUenkuZ5ryUSpeGjJPO7xgbMObZ5SeBs8/LKU3ROo4g=";
  };

  cargoHash = "sha256-WmHrMALgP52OJH1acrB7DMgo/8FMgksPyXpeRL9Q7s0=";

  postInstall = ''
    install -Dm644 fsel.1 $out/share/man/man1/fsel.1
  '';

  meta = {
    description = "Fast TUI app launcher for GNU/Linux and *BSD";
    homepage = "https://github.com/Mjoyufull/fsel";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dtomvan ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "fsel";
  };
})
