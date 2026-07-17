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
  version = "1.4.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "git-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jS84CRiQiyTuEDzgQxD8MJYDIabTjAuYCUXiqBjAT0c=";
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
