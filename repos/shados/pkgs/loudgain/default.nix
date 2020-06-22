{ stdenv, fetchFromGitHub, cmake, pkgconfig
, ffmpeg, libebur128, taglib
}:
stdenv.mkDerivation rec {
  pname = "loudgain";
  version = "unstable-2019-11-03";

  src = fetchFromGitHub {
    owner = "Moonbase59"; repo = pname;
    rev = "0ff67eec6cc2d37df1cd9d0bd95c5076604a23bc";
    sha256 = "1yn1wz3w0zkwgd8xqb0j1y8909s6klv5g107dl1aw21gdjavnlc5";
  };

  nativeBuildInputs = [
    cmake pkgconfig
  ];

  buildInputs = [
    ffmpeg libebur128 taglib
  ];

  meta = with stdenv.lib; {
    description = "ReplayGain 2.0 loudness normalizer based on the EBU R128/ITU BS.1770 standard";
    homepage    = https://github.com/Moonbase59/loudgain;
    maintainers = with maintainers; [ arobyn ];
    platforms   =  [ "x86_64-linux" ];
    license     = licenses.bsd2;
  };
}
