{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aria-csv";
  version = "git";

  src = fetchFromGitHub {
    owner = "AriaFallah";
    repo = "csv-parser";
    rev = "544c764d0585c61d4c3bd3a023a825f3d7de1f31";
    sha256 = "sha256-KTuJHDDj1BYmpa+bRseZftCQxpcyf0Yy33osI/79BW8=";
  };

  installPhase = ''
    mkdir -p $out/include/aria-csv
    cp parser.hpp $out/include/aria-csv
    '';

  postFixup = ''
    mkdir -p $out/lib/pkgconfig
    echo "
prefix=$out/include/aria-csv
includedir=$out/include/aria-csv

Name: AriaCsv 
Description: Fast, header-only, C++11 CSV parser.
Version: $version
Cflags: -I$out/include/aria-csv" > $out/lib/pkgconfig/aria-csv.pc
    '';

  meta = with lib; {
    description = "Fast, header-only, C++11 CSV parser.";
    homepage = "https://github.com/AriaFallah/csv-parser";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
