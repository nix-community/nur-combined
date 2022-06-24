{ aria-csv-cmake, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "aria-csv";
  version = "git";

  src = fetchFromGitHub {
    owner = "AriaFallah";
    repo = "csv-parser";
    rev = "70aa4793533ce9a04942cfe5af29c2b93c044e58";
    sha256 = "sha256-VNU3yASc5W43KojYg6Q3TiLTndKd6zyoiGYDxV2XMk0=";
  };

  installPhase = ''
    mkdir -p $out/include/aria-csv
    mkdir -p $out/share/aria-csv
    cp parser.hpp $out/include/aria-csv
    cp ${aria-csv-cmake}/* $out/share/aria-csv/
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

    sed -i "s|ARIACSV_INCLUDE_DIR|$out/include|g" $out/share/aria-csv/aria-csv-targets.cmake
    '';

  meta = with lib; {
    description = "Fast, header-only, C++11 CSV parser.";
    homepage = "https://github.com/AriaFallah/csv-parser";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
