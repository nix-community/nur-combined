{ pkgs ? import <nixpkgs> {} }:
with pkgs;

stdenv.mkDerivation rec {
  pname = "quantlib";
  version = "1.21";

  meta = with lib; {
    description = "A free/open-source library for quantitative finance";
    homepage = "https://www.quantlib.org/";
    platforms = platforms.all;
  };

  src = fetchurl {
    url = "https://github.com/lballabio/QuantLib/releases/download/QuantLib-v${version}/QuantLib-${version}.tar.gz";
    sha256 = "06vxp0jrgk5lh1yxcchfbssd380v5d7614h6k1mxw8pq2gxrccix";
  };

  buildInputs = [ boost ];

  enableParallelBuilding = true;
}
