{ lib, stdenv, fetchFromGitHub, libiconv }:

stdenv.mkDerivation rec {
  pname = "gimgtools";
  version = "2013-09-19";

  src = fetchFromGitHub {
    owner = "wuyongzheng";
    repo = "gimgtools";
    rev = "92d015749e105c5fb8eb704ae503a5c7e51af2bd";
    hash = "sha256-AgZqczhYr5frD9Id75if/38O057BC6YfeGquFpidKZI=";
  };

  buildInputs = lib.optional stdenv.isDarwin libiconv;

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" ""
  '';

  installPhase = ''
    for tool in gimginfo gimgfixcmd gimgxor gimgunlock gimgch gimgextract cmdc; do
      install -Dm755 $tool -t $out/bin
    done
  '';

  meta = with lib; {
    description = "Garmin Image Tools";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
