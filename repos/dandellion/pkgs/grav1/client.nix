{ lib, stdenv, python3, fetchFromGitHub, ffmpeg, libaom, libvpx, dav1d, makeWrapper }:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    requests
  ]);
in
stdenv.mkDerivation { 
  pname = "grav1c";
  version = "0.0.0-20200708";

  src = fetchFromGitHub {
    owner = "wwww-wwww";
    repo = "grav1";
    rev = "975e16d7fedc2d4f012c694cb5b1b0876c3cac01";
    sha256 = "11vingnczwy7wxrzp0hqij0jwwzbwjjd8l35wk2zps28npazaly3";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/bin
    cp grav1c.py $out/bin/grav1c
    chmod +x $out/bin/grav1c

    wrapProgram $out/bin/grav1c \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg libaom libvpx (dav1d.override { withTools = true; }) ]}
  '';

}
