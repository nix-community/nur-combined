{ stdenv, lib, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "rederr";

  src = fetchFromGitHub {
    owner = "poettering";
    repo = name;
    rev = "f5903346e2722c27c314e4546fba2499ed8846ce";
    sha256 = "1j76mv2bydi416d2s6s2hs52qimfk47818myqk48d6h3q11lnrh5";
  };

  buildPhase = ''
    gcc -o rederr rederr.c -std=gnu99
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp rederr $out/bin
  '';

  meta = with lib; {
    description = "Colour your stderr red";
    license = licenses.lgpl2Plus;
    homepage = https://github.com/poettering/rederr;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

