{ stdenv, lib, fetchFromGitHub, autoconf, automake, alsaLib, libpulseaudio, libjack2 }:

stdenv.mkDerivation rec {
  name = "vban";
  version = "2020-02-21";

  src = fetchFromGitHub {
    owner = "quiniouben";
    repo = name;
    rev = "9845c22d86cc45007f19ec61154202c999519e41";
    sha256 = "1qnl97c58ypp6r9ypq4zlqbzwyr07qz7r766byhlrs2w5b83r3fj";
  };

  nativeBuildInputs = [ autoconf automake ];
  buildInputs = [ alsaLib libpulseaudio libjack2 ];

  preConfigure = "./autogen.sh";

  meta = with stdenv.lib; {
    description = "a simple audio over UDP protocol proposed by VB-Audio";
    homepage = https://github.com/quiniouben/vban;
    license = licenses.gpl3;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}