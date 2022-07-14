{ pkgs, lib, imagemagick, jp2a, fetchFromGitHub, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "pulseaudio-virtualmic";
  owner = "MatthiasCoppens";
  name = pname;
  version = "03115fa677b8a2704a929a063d8eca7b2f8219f1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-qKUh6vTrd5Ucj1376PpK9ap7IArahVAVjRsxsOMZ0wI=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp virtualmic $out/bin/
    chmod +x $out/bin/*
  '';

  meta = with lib; {
    description = "Use any offline or online media file or stream as a PulseAudio source";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.gpl3;
  };
}
