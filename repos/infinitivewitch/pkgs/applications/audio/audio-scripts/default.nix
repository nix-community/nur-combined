{ stdenv, fetchzip, lib, ... }:
stdenv.mkDerivation rec {
  name = "audio-scripts";
  version = "7999d1c4d43b798ed8db98d751536459d056d88f";
  src = fetchzip {
    url = "https://github.com/eupnea-linux/${name}/archive/${version}.zip";
    sha256 = "sha256-qzcnM6fBxOt1anZQ4Ot04VNb1Y9m0WzgBCp8SgT28Rw=";
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
