{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mtk-suomi";
  version = "2025-10-04";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${finalAttrs.version}/mtk_suomi.img";
    hash = "sha256-j/2NS3THjqFPdBamPlyPvT4/CX63dh+XEdiSROT/CUY=";
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
