{ stdenv, fetchzip, lib, ... }:
let
  src = fetchzip {
    url = "https://github.com/eupnea-linux/audio-scripts/archive/refs/heads/main.zip";
    sha256 = "sha256-qzcnM6fBxOt1anZQ4Ot04VNb1Y9m0WzgBCp8SgT28Rw=";
  };
in
stdenv.mkDerivation rec {
  name = "chromebook-audio";
  version = "0.0.1";
  inherit src;

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
