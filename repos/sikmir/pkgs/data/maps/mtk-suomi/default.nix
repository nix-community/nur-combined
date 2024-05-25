{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mtk-suomi";
  version = "2024-01-23";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${finalAttrs.version}/mtk_suomi.img";
    hash = "sha256-DDAJwJdcluqzo6U/zzkUZ1aq6QSDspnLpNzLsgejcz0=";
  };

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = "install -Dm644 $src $out/mtk_suomi.img";

  meta = {
    description = "Maanmittauslaitoksen peruskartan tasoiset ja näköiset ilmaiset maastokartat";
    homepage = "https://kartat.hylly.org/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
