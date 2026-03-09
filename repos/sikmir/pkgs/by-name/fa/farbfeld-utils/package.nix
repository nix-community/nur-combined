{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libX11,
  libxrender,
  SDL,
  ghostscript,
  sqlite,
}:

stdenv.mkDerivation {
  pname = "farbfeld-utils";
  version = "0-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "bakkeby";
    repo = "farbfeld-utils";
    rev = "123fc1060d554a67f8c7f1ba9e9c60fe10a48730";
    hash = "sha256-oXTMnTsldf5IoKL6O4HtMmUAyJTy75PH0gBmO81a9Wo=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    rm ff-vccapture.c ff-xcapture.c ff-xdraw.c ff-xwin.c
  '';

  buildInputs = [
    libGL
    SDL
    ghostscript
    sqlite
  ]
  ++ lib.optionals stdenv.isLinux [
    libX11
    libxrender
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    $CC -c lodepng.c
    find . -name '*.c' -exec grep 'gcc' {} + -print0 | \
      awk -F: '{print $2}' | sed 's#~/bin#$out/bin#;s#gcc#$CC#;s#/usr/lib/libgs.so#-lgs#;s#sqlite3.o#-lsqlite#' | xargs -0 sh -c

    runHook postBuild
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration -Wno-error=return-mismatch -Wno-error=implicit-int";

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Collection of utilities for farbfeld picture format";
    homepage = "http://zzo38computer.org/fossil/farbfeld.ui/home";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
