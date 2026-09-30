{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fsel";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    tag = finalAttrs.version;
    hash = "sha256-+KzmiWJqtM6lJL/aWYvU2XuLT7k8FqTWsVWn8hWOMRc=";
  };

  cargoHash = "sha256-Vo3J2/XphNhvYkt4oasB2Z6OOj/nez7agSJZJbu+h1I=";

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
