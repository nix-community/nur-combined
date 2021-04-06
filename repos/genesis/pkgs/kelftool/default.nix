{ lib, stdenv, fetchFromGitHub, openssl }:

stdenv.mkDerivation rec {
  version = "unstable-2021-05-03";
  pname = "kelftool";

  src = fetchFromGitHub {
    owner = "parrado";
    repo = "kelftool";
    rev = "befdc6b103cedae7ba11ba55b28bdd6f60f90533";
    sha256 = "sha256-sTbU6y6gOiiXNeZrrfm171SirS4qeipmhrtwVyduQtQ=";
  };

  buildInputs = [ openssl ];

  installPhase = ''
    mv build/kelftool.elf build/kelftool
    install -Dm755 build/kelftool -t $out/bin/
  '';


  meta = with lib; {
    inherit (src.meta) homepage;
    description = "PlayStation 2 utility for decrypt, encrypt and sign PS2 KELF and PSX KELF files";
    platforms = platforms.linux;
    license = licenses.gpl3;
    maintainers = with maintainers; [ genesis ];
  };
}
