{
  lib,
  stdenv,
  fetchFromGitHub,
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
  version = "2.14";

  src = fetchFromGitHub {
    owner = "slazav";
    repo = "graphene";
    tag = finalAttrs.version;
    hash = "sha256-vE1dmCPbrjHknkk66797dD98Uz5ts2wwDmuMWv/bUFI=";
    fetchSubmodules = true;
  };

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
