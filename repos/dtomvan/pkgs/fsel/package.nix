{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-g4LWJrY62VJ0qN/n+eoPt3uL7b4fLtGoDAT86I9jbco=";
  };

  cargoHash = "sha256-G1wfue1Q+3NMH/5NqPVKeO0NpU0WJlwWkh51r3TM5IM=";

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
