{ stdenv, lib, pkgs, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "bin2iso";
  version = "1.9b";

  src = fetchFromGitHub {
    owner = "einsteinx2";
    repo = "bin2iso";
    rev = "a08f6f93b833878dc009fe59da072643f06a7830";
    sha256 = "1bnhj8z7wbq2v070zkx0xal6hx37y20a068gpy95zh13vihvbgh3";
  };

  buildPhase =''
    gcc -Wall -o $pname $src/src/linux_macos/${pname}_v${version}_linux.c
  '';

  installPhase = ''
    install -Dm755 $pname $out/bin/$pname
  '';

  meta = {
    homepage = https://github.com/einsteinx2/bin2iso;
    description = "converts bin+cue to iso";
    license = lib.licenses.gpl3;
  };
}
