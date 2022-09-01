{ lib, stdenv, fetchFromGitHub, libX11 }:

stdenv.mkDerivation rec {
  pname = "pista";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "xandkar";
    repo = "pista";
    rev = version;
    hash = "sha256-lre6SIVyxCwEohLlvSfYs+JnHS1VXTbl3FlUNZ3TGy4=";
  };

  buildInputs = [ libX11 ];

  installPhase = ''
    install -Dm755 pista -t $out/bin
  '';

  meta = with lib; {
    description = "Piped status: the ii of status bars!";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
