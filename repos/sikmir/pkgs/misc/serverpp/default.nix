{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  gsl-lite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serverpp";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "serverpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SV+1RrKvDK8OGTGHjCyl5uuRbh/0TMTtC3ax0++HOCI=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    gsl-lite
  ];

  meta = {
    description = "A C++ library for basic network server handling";
    homepage = "https://github.com/KazDragon/serverpp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin;
  };
})
