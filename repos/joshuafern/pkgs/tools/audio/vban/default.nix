{ stdenv, lib, fetchFromGitHub, autoconf, automake, autoreconfHook, alsaLib, libpulseaudio
, libjack2 }:

stdenv.mkDerivation rec {
  pname = "vban";
  version = "unstable-2020-02-21";

  src = fetchFromGitHub {
    owner = "quiniouben";
    repo = pname;
    rev = "9845c22d86cc45007f19ec61154202c999519e41";
    sha256 = "1qnl97c58ypp6r9ypq4zlqbzwyr07qz7r766byhlrs2w5b83r3fj";
  };

  nativeBuildInputs = [ autoconf automake autoreconfHook ];
  buildInputs = [ alsaLib libpulseaudio libjack2 ];

  meta = with stdenv.lib; {
    description = "A simple audio over UDP protocol proposed by VB-Audio";
    homepage = "https://github.com/quiniouben/vban";
    license = licenses.gpl3;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}