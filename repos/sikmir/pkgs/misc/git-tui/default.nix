{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ftxui,
  subprocess,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-tui";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "git-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RogDZeDgC7HanPd0I+BuU9CShUzaIqvH1R7/I1tAtG4=";
  };

  patches = [ ./subprocess.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ftxui
    subprocess
  ];

  meta = {
    description = "Collection of human friendly terminal interface for git";
    homepage = "https://github.com/ArthurSonzogni/git-tui";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
