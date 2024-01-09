{ lib, stdenv, fetchFromGitHub, bmake, pkg-config, libbsd, imsg-compat, sndio, flac, mpg123, libvorbis, opusfile }:

stdenv.mkDerivation (finalAttrs: {
  pname = "amused";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = "amused";
    rev = finalAttrs.version;
    hash = "sha256-VqCiSEKwWeqe5ecsLFjFQJ4n1kPvyGWMfsyjqp2XVDU=";
  };

  nativeBuildInputs = [ bmake pkg-config ];

  buildInputs = [ libbsd imsg-compat sndio flac mpg123 libvorbis opusfile ];

  meta = with lib; {
    description = "music player daemon NIH";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
