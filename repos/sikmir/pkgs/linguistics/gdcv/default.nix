{ lib, stdenv, fetchFromGitHub, pkg-config, argp-standalone, emacs, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdcv";
  version = "2023-08-27";

  src = fetchFromGitHub {
    owner = "konstare";
    repo = "gdcv";
    rev = "3151309d57d147231c63bd51fd0f01f10fd6ea55";
    hash = "sha256-fzR+HKAZmvjiL4pBqfi3xIl5Ju0W3Hpy3SDHOmgoWZ0=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile \
      --replace-fail "CC=gcc" ""

    substituteInPlace gdcv.c \
      --replace-fail "#include <error.h>" ""

    substituteInPlace index.c \
      --replace-fail "|FNM_EXTMATCH" ""
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ emacs zlib ] ++ lib.optional stdenv.isDarwin argp-standalone;

  makeFlags = [ "gdcv" "emacs-module" ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-largp";

  installPhase = ''
    install -Dm755 gdcv -t $out/bin
    install -Dm644 gdcv-elisp.so gdcv.el -t $out/share/emacs/site-lisp
  '';

  meta = with lib; {
    description = "GoldenDict console version and emacs dynamic module";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = stdenv.isDarwin;
  };
})
