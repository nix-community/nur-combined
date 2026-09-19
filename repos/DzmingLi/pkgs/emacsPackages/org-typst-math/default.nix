{
  lib,
  emacsPackages,
  fetchFromGitHub,
}:

## DzmingLi/org-typst-math: write Typst mathematics inside Org.
##
## Only the Elisp side is packaged here.  The persistent Rust helper
## (`org-typst-math-helper`) is a separate program; set `typst-client-command'
## to its store path to actually render or convert Typst math.
emacsPackages.trivialBuild {
  pname = "org-typst-math";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DzmingLi";
    repo = "org-typst-math";
    rev = "e26040a713b2e2c0d12f4289497b58198137cc49";
    hash = "sha256-dJWYpZFdvrg0kE3cOV4MnXezegFSioHrb9c5OylwRAY=";
  };

  postPatch = ''
    mv lisp/*.el .
  '';

  turnCompilationWarningToError = true;

  doCheck = false;

  meta = with lib; {
    description = "Typst mathematics inside Org";
    homepage = "https://github.com/DzmingLi/org-typst-math";
    platforms = platforms.unix;
  };
}
