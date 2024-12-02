{ pkgs, lib, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "otrecorder";
  name = pname;
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "owntracks";
    repo = "recorder";
    rev = version;
    sha256 = "sha256-6oCWzTiQgpp75xojd2ZFsrg+Kd5/gex1BPQVOWHfMuk=";
  };

  nativeBuildInputs = with pkgs; [ mosquitto curl lmdb libconfig libuuid ];

  configurePhase = ''
    cp config.mk.in config.mk
  '';

  installPhase = ''
    mkdir -p $out/bin $out/usr/share/ot-recorder
    cp ot-recorder $out/bin/ot-recorder
    cp -R docroot/* $out/usr/share/ot-recorder
  '';

  meta = with lib; {
    description = "Store and access data published by OwnTracks apps";
    homepage = "https://github.com/owntracks/recorder";
    license = licenses.gpl2;
  };
}
