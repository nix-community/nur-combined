{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "kose-font";
  version = "20210514";

  src = fetchFromGitHub {
    owner = "lxgw";
    repo = "kose-font";
    rev = "0d24786398fc8047b0b56b6dc521a02a2dcfd0d2";
    sha256 = "sha256-223NxerR6JeSPKymt3DPvPRRgiE+JOXalKXBGA1eipE=";
  };

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/kose-font '{}' ';'

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/lxgw/kose-font";
    description = "A Chinese handwriting font derived from SetoFont / Naikai Font / cjkFonts-AllSeto.";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
