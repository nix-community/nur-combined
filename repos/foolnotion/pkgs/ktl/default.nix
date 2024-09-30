{ lib, stdenv, fetchFromGitHub, cmake, cmake-utils }:
stdenv.mkDerivation rec {
  pname = "ktl";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "karnkaul";
    repo = "ktl";
    rev = "v.${version}";
    hash = "sha256-5rLjW2oDuo/37jx7fDveGJGHP5HGBVL/MzMbCNf9VrM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DKTL_INSTALL=ON" "-DFETCHCONTENT_SOURCE_DIR_CMAKE-UTILS=${cmake-utils}" ];

  meta = with lib; {
    description = "A lightweight set of utility headers written in C++20.";
    homepage = "https://github.com/karnkaul/ktl";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
