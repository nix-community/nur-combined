#{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook }:
{ stdenv, lib, fetchurl, autoPatchelfHook, dpkg, bzip2
, alsaLib, qt5, libjack2, openssl_1_0_2, libpulseaudio, lbzip2 }:

stdenv.mkDerivation rec {
  pname = "ocenaudio";
  version = "3.7.20";

  src = fetchurl {
    url = "https://www.ocenaudio.com/downloads/index.php/ocenaudio_debian64.deb?version=${version}";
    sha256 = "0byr57rsnalkvc1jk7wjmjlvjd2ajvspkffpw81yxkfhvmvvjzrz";
  };


  nativeBuildInputs = [
    autoPatchelfHook
    qt5.qtbase
    libjack2
    openssl_1_0_2
    libpulseaudio
    bzip2
    alsaLib
  ];

  buildInputs = [ dpkg ];

  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    cp -av $out/opt/ocenaudio/* $out
    rm -rf $out/opt

    # Create symlink bzip2 library
    ln -s ${bzip2.out}/lib/libbz2.so.1 $out/libbz2.so.1.0
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform, easy to use, fast and functional audio editor";
    homepage = "https://www.ocenaudio.com";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
