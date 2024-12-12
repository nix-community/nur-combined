{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  perl,
  libevent,
  openssl,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aprsc";
  version = "2.1.19";

  src = fetchFromGitHub {
    owner = "hessu";
    repo = "aprsc";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-cScXe6QbC+hqd86uvhglARzBuihSWYvAC7RxVljZwFk=";
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

  buildInputs = [
    libevent
    openssl
  ];

  preConfigure = "LD=$CC";
  configureFlags = [
    (lib.withFeature true "openssl")
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

  meta = {
    description = "A core APRS-IS server";
    homepage = "http://he.fi/aprsc/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
