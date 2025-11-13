{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  perl,
  pkg-config,
  wget,
  db,
  libmicrohttpd,
  jansson,
  tcl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "graphene";
  version = "2.13";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "graphene";
    tag = finalAttrs.version;
    hash = "sha256-N7Pdf/8+Yi+OBRvJMkz2EyRQOsnBYs5BQeO20JP8tWA=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/slazav/graphene/commit/76027a4a04e32a2d457934ab434788eeb27f60e4.patch";
      hash = "sha256-9IRrcgaW1Hmrw8ox+mDn1MzlZD/4RYH3qM2K91mW54M=";
    })
  ];

  postPatch = ''
    patchShebangs .
    substituteInPlace graphene/Makefile --replace-fail "graphene_http.test2" ""
  '';

  nativeBuildInputs = [
    perl
    pkg-config
    wget
  ];

  buildInputs = [
    db
    libmicrohttpd
    jansson
    tcl
  ];

  installFlags = [
    "prefix=$(out)"
    "sysconfdir=$(out)/etc"
  ];

  doCheck = false;

  meta = {
    description = "A simple time series database based on BerkleyDB";
    homepage = "https://github.com/slazav/graphene";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
