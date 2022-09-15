{ lib, stdenv, fetchFromGitHub, fetchpatch, perl, libevent, openssl, testers }:

stdenv.mkDerivation (finalAttrs: {
  pname = "aprsc";
  version = "2.1.11";

  src = fetchFromGitHub {
    owner = "hessu";
    repo = "aprsc";
    rev = "release/${finalAttrs.version}";
    hash = "sha256-lPVhGYdd80XCXgOD8m09LvudbC6poNhSRS2ILcapMwE=";
  };

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/54cc4cc6eaed14e3d495ca3a3b6f86f3f429b991/net/aprsc/files/patch-Makefile.in";
      hash = "sha256-lxnE/9fgnxZxIcb9bNcq4PoOIBntIdyVYJa5rPIx26s=";
    })
  ];
  patchFlags = [ "-p0" ];

  sourceRoot = "${finalAttrs.src.name}/src";

  nativeBuildInputs = [ perl ];

  buildInputs = [ libevent openssl ];

  preConfigure = "LD=$CC";
  configureFlags = [
    "--with-openssl"
    "--mandir=$(out)/share/man"
  ];

  makeFlags = [
    "GIT_CMD:="
    "GITVERSION:=release"
    "DATE:=1970-01-01T00:00:00+0000"
    "BUILD_TIME:=1970-01-01T00:00:00+0000"
    "BUILD_USER:=nixbld"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    command = "! aprsc -h";
    version = "${finalAttrs.version}-release";
  };

  meta = with lib; {
    description = "A core APRS-IS server";
    homepage = "http://he.fi/aprsc/";
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
