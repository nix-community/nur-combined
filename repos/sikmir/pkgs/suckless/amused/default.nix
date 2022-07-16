{ lib, stdenv, fetchFromGitHub, bmake, pkg-config, libbsd, imsg-compat, sndio, libevent, flac, mpg123, libvorbis, opusfile }:

stdenv.mkDerivation rec {
  pname = "amused";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-A2f37oI3BT30bqRYgoWy4B1dvPeZBoE4F3lkmET0td8=";
  };

  nativeBuildInputs = [ bmake pkg-config ];

  buildInputs = [ libbsd libevent imsg-compat sndio flac mpg123 libvorbis opusfile ];

  meta = with lib; {
    description = "music player daemon NIH";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
