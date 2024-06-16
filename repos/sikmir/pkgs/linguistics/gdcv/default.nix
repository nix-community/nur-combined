{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  argp-standalone,
  emacs,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdcv";
  version = "0-unstable-2023-08-27";

  src = fetchFromGitHub {
    owner = "konstare";
    repo = "gdcv";
    rev = "3151309d57d147231c63bd51fd0f01f10fd6ea55";
    hash = "sha256-fzR+HKAZmvjiL4pBqfi3xIl5Ju0W3Hpy3SDHOmgoWZ0=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace gdcv.c \
      --replace-fail "#include <error.h>" ""

    substituteInPlace index.c \
      --replace-fail "|FNM_EXTMATCH" ""
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    emacs
    zlib
  ] ++ lib.optional stdenv.isDarwin argp-standalone;

  makeFlags = [
    "CC:=$(CC)"
    "gdcv"
    "emacs-module"
  ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-largp";

  installPhase = ''
    runHook preInstall
    install -Dm755 gdcv -t $out/bin
    install -Dm644 gdcv-elisp.so gdcv.el -t $out/share/emacs/site-lisp
    runHook postInstall
  '';

  meta = {
    description = "GoldenDict console version and emacs dynamic module";
    homepage = "https://github.com/konstare/gdcv";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = stdenv.isDarwin;
    mainProgram = "gdcv";
  };
})
