{ lib, stdenv, python3, fetchFromGitHub, ffmpeg, libaom, libvpx, dav1d, makeWrapper }:

let
  pythonEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    requests
  ]);
in
stdenv.mkDerivation { 
  pname = "grav1c";
  version = "0.0.0-20200811";

  src = fetchFromGitHub {
    owner = "wwww-wwww";
    repo = "grav1";
    rev = "f0e713a399ffb287835a0c5ea31e02cd9babbe34";
    sha256 = "025jqhdh5ysgca9yj0q1ld0s1y30bzfbb57wgr78wja61ywnqmgy";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out/bin
    cp client.py $out/bin/grav1c
    chmod +x $out/bin/grav1c

    wrapProgram $out/bin/grav1c \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg libaom libvpx (dav1d.override { withTools = true; }) ]}
  '';

}
