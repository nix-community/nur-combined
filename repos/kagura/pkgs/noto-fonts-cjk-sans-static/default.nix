# Author: https://github.com/NixOS/nixpkgs/pull/355026/files#diff-ab5748dc9567516fefba8344056b51ec1866adeace380f46e58a7af3d619ea22
# remove static option as this package is meant to be always using static version
# this package can be useful if you are using typst
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gitUpdater,
}:

stdenvNoCC.mkDerivation rec {
  pname = "noto-fonts-cjk-sans-static";
  version = "2.004";

  src = fetchFromGitHub {
    owner = "notofonts";
    repo = "noto-cjk";
    rev = "Sans${version}";
    hash = "sha256-i3ZKoSy2SVs46IViha+Sg8atH4n3ywgrunHPLtVT4Pk=";
    sparseCheckout = [
      "Sans/OTC"
      "Sans/Variable/OTC"
    ];
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "Sans";
  };

  meta = {
    description = "Beautiful and free fonts for CJK languages";
    homepage = "https://www.google.com/get/noto/help/cjk/";
    longDescription = ''
      Noto Sans CJK is a sans typeface designed as
      an intermediate style between the modern and traditional. It is
      intended to be a multi-purpose digital font for user interface
      designs, digital content, reading on laptops, mobile devices, and
      electronic books. Noto Sans CJK comprehensively covers
      Simplified Chinese, Traditional Chinese, Japanese, and Korean in a
      unified font family. It supports regional variants of ideographic
      characters for each of the four languages. In addition, it supports
      Japanese kana, vertical forms, and variant characters (itaiji); it
      supports Korean hangeul — both contemporary and archaic.
    '';
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      mathnerd314
      emily
    ];
  };
}