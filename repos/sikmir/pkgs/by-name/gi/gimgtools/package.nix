{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gimgtools";
  version = "0.01-unstable-2013-09-19";

  src = fetchFromGitHub {
    owner = "wuyongzheng";
    repo = "gimgtools";
    rev = "92d015749e105c5fb8eb704ae503a5c7e51af2bd";
    hash = "sha256-AgZqczhYr5frD9Id75if/38O057BC6YfeGquFpidKZI=";
  };

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;

  makeFlags = [ "CC:=$(CC)" ];

  installPhase = ''
    for tool in gimginfo gimgfixcmd gimgxor gimgunlock gimgch gimgextract cmdc; do
      install -Dm755 $tool -t $out/bin
    done
  '';

  meta = {
    description = "Garmin Image Tools";
    homepage = "https://github.com/wuyongzheng/gimgtools";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin;
  };
})
