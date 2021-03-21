{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "exo2";
  version = "unstable-2020-03-09";

  src = fetchFromGitHub {
    owner = "NDISCOVER";
    repo = "Exo-2.0";
    rev = "6ce85fdb06fc174d485ad70a15afbcbf23ff2b53";
    sha256 = "12bhx8gj46sx4ky8w58chpddqk5xqb1xbbciar51a0h7fpps13wj";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    install -m644 --target $out/share/fonts/truetype/${pname} -D $src/fonts/ttf/*.ttf
  '';

  meta = with lib; {
    homepage = "https://github.com/NDISCOVER/Exo-2.0";
    description = "Exo 2 is a complete redrawing of Exo";
    maintainers = with maintainers; [ ilya-fedin ];
    license = licenses.ofl;
    platforms = platforms.all;
  };
}