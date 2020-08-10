{ stdenv, fetchgit, libX11 }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dwmblocks";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dwmblocks";
    rev = "8b313712dc8000ce65b229e3089f429bc9fc8cd9";
    sha256 = "1a4i4bbmw9f9wljk8g979ypsnr7199wxx8dj1vadcq4k33szgzyj";
  };

  buildInputs = [ libX11 ];

  installPhase = ''
    make install PREFIX=$out
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/dwmblocks";
    description = "Luke's build of dwmblocks";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
