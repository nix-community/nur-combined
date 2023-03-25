{ stdenv, fetchzip, lib, ... }:
stdenv.mkDerivation rec {
  name = "audio-scripts";
  version = "a4046df34d7f58693590ede2945fe9a38bcbc3e6";
  src = fetchzip {
    url = "https://github.com/eupnea-linux/${name}/archive/${version}.zip";
    sha256 = "sha256-IrSX2I/omrchqrFuP060/BEAdM63/O3/zRtXrQ/QLLA=";
  };

  installPhase = ''
    cp -r $src $out
  '';

  meta = with lib; {
    description = "Audio scripts for Eupnea written in python";
    homepage = "https://github.com/eupnea-linux/audio-scripts";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ /*infinitivewitch*/ ];
    platforms = platforms.linux;
  };
}
