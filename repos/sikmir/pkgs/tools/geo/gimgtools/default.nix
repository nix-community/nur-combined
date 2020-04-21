{ stdenv, sources, libiconv }:

stdenv.mkDerivation rec {
  pname = "gimgtools";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.gimgtools;

  buildInputs = stdenv.lib.optional stdenv.isDarwin libiconv;

  postPatch = stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile \
      --replace "CC = gcc" ""
  '';

  installPhase = ''
    for tool in gimginfo gimgfixcmd gimgxor gimgunlock gimgch gimgextract cmdc; do
      install -Dm755 $tool $out/bin/$tool
    done
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
