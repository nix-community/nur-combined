{ lib, stdenv, python3, wsgiserver, fetchFromGitHub, ffmpeg, libaom, libvpx, dav1d, setuptools, makeWrapper }:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    flask
    flask-cors
    wsgiserver
    enzyme
    requests
    setuptools
  ]);
in
stdenv.mkDerivation { 
  pname = "grav1";
  version = "0.0.0-20200811";

  src = fetchFromGitHub {
    owner = "wwww-wwww";
    fetchSubmodules = true;
    repo = "grav1";
    rev = "f0e713a399ffb287835a0c5ea31e02cd9babbe34";
    sha256 = "00s7w8gx5718zp8d7iqvya1sv9grcca73ciw4hbqkd1pfigg6x8y";
  };

#  src = ./grav1;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/grav1 $out/bin
    cp -r * $out/grav1
    rm $out/grav1/client.py
    ln -s $out/grav1/server.py $out/bin/server
    chmod +x $out/bin/server

    wrapProgram $out/bin/server \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg libaom libvpx (dav1d.override { withTools = true;}) ]}
  '';

}
