{
  lib,
  stdenv,
  fetchFromGitHub,
  bmake,
  pkg-config,
  libbsd,
  imsg-compat,
  sndio,
  flac,
  mpg123,
  libvorbis,
  opusfile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amused";
  version = "0.19";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = "amused";
    tag = finalAttrs.version;
    hash = "sha256-VF+Jm4dz6Pd4WYBBTgjFN0VpJUVxkQhP+URosvmN8pU=";
  };

  nativeBuildInputs = [
    bmake
    pkg-config
  ];

  buildInputs = [
    libbsd
    imsg-compat
    sndio
    flac
    mpg123
    libvorbis
    opusfile
  ];

  meta = {
    description = "music player daemon NIH";
    homepage = "https://github.com/omar-polo/amused";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
