{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "3.5.2";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-XGKD/DId5Eont4ytPV7LfGvykDRalMWx4pbkRVUNzxY=";
  };

  cargoHash = "sha256-SAQnY0VgRPLjkjmEgZcyjp6hFXxp54PB1j52qwAy9yI=";

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
