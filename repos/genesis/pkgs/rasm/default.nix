{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "rasm";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "EdouardBERGE";
    repo = "rasm";
    rev = "v${version}";
    sha256 = "sha256-mMn22FAir+fPHpPgbX3ISA3CoAzfjIZk7oi7KzYhdMA=";
  };

  makeFlags = [ "EXEC=rasm" ];
  installPhase = ''
    install -Dt $out/bin rasm
  '';

  meta = with lib; {
    homepage = "http://www.roudoudou.com/rasm/";
    description = "Z80 assembler";
    # use -n option to display all licenses
    license = licenses.mit; # expat version
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux;
  };
}
