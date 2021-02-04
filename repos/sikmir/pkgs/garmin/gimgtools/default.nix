{ lib, stdenv, sources, libiconv }:

stdenv.mkDerivation {
  pname = "gimgtools-unstable";
  version = lib.substring 0 10 sources.gimgtools.date;

  src = sources.gimgtools;

  buildInputs = lib.optional stdenv.isDarwin libiconv;

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace Makefile \
      --replace "CC = gcc" ""
  '';

  installPhase = ''
    for tool in gimginfo gimgfixcmd gimgxor gimgunlock gimgch gimgextract cmdc; do
      install -Dm755 $tool -t $out/bin
    done
  '';

  meta = with lib; {
    inherit (sources.gimgtools) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
