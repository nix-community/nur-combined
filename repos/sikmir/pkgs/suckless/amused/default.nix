{ lib, stdenv, fetchFromGitHub, bmake, libbsd, imsg-compat, sndio, libevent, flac, mpg123, libvorbis, opusfile }:

stdenv.mkDerivation rec {
  pname = "amused";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-L2YumBk3KiVzLmFWVS7a5xe9PRkbg/MFNxSktXbRLuw=";
  };

  patches = [ ./linux.patch ];

  nativeBuildInputs = [ bmake ];

  buildInputs = [ libbsd libevent imsg-compat sndio flac mpg123 libvorbis opusfile ];

  makeFlags = [
    "AMUSED_RELEASE=Yes"
    "CC:=$(CC)"
    "CPPFLAGS=-I${opusfile}/include/opus -I${libbsd}/include/bsd -I${imsg-compat}/include"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "music player daemon NIH";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true; # WIP https://github.com/omar-polo/amused/issues/1
  };
}
