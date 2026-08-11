{ stdenv, fetchFromGitHub, fetchurl, lib, p7zip }:

# Based on instructions here: https://github.com/tolga9009/elgato-gchd/wiki/Firmware

stdenv.mkDerivation rec {
  pname = "elgato-gchd-firmware";
  version = "3.70.42.3042-x64";
  
  src = fetchurl {
    url = "https://edge.elgato.com/egc/windows/egcw/3.70/final/GameCaptureSetup_3.70.42.3042_x64.msi";
    sha256 = "16bl4x0d1hc7nzzcrywj6073yn5hc27wmq6xgk6yii06wz1cghi1";
  };
  phases = ["buildPhase"];
  buildInputs = [ p7zip ];

  buildPhase = ''
  filename=${src}
  TEMPDIR=`mktemp -d`
  mkdir $TEMPDIR/gchd

  7z e -o$TEMPDIR $filename x86_yPushFile3.dll
  7z e -o$TEMPDIR/gchd -r $TEMPDIR/x86_yPushFile3.dll MB86H57_H58_IDLE MB86H57_H58_ENC_H MB86M01_ASSP_NSEC_IDLE MB86M01_ASSP_NSEC_ENC_H

  rm -f $TEMPDIR/x86_yPushFile3.dll
  pushd $TEMPDIR
  mkdir -p "$out/lib/firmware/gchd"
  cp gchd/* $out/lib/firmware/gchd
  '';

  meta = with stdenv.lib; {
    description = "elgato game capture firmware";
    homepage = "https://www.elgato.com/en/gaming/downloads";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };



}
