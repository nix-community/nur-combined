{ lib, stdenv, fetchFromGitHub, bmake, pkg-config, libbsd, imsg-compat, sndio, libevent, flac, mpg123, libvorbis, opusfile }:

stdenv.mkDerivation rec {
  pname = "amused";
  version = "2022-07-09";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = "33e8ddf3b1df91d66664dcf0dc7011d089a74611";
    hash = "sha256-GNNkbd9f0fUArzDiMdnJ0JTwhsTBRyH/Z8t7287hWtg=";
  };

  nativeBuildInputs = [ bmake pkg-config ];

  buildInputs = [ libbsd libevent imsg-compat sndio flac mpg123 libvorbis opusfile ];

  meta = with lib; {
    description = "music player daemon NIH";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
