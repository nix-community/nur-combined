{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mtk-suomi";
  version = "2023-04-08";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${finalAttrs.version}/mtk_suomi.img";
    hash = "sha256-Jjm8c9wiPyQYoBGgFmFFVjG8Ur2nx6CndbmhGX/nSLo=";
  };

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = "install -Dm644 $src $out/mtk_suomi.img";

  meta = with lib; {
    description = "Maanmittauslaitoksen peruskartan tasoiset ja näköiset ilmaiset maastokartat";
    homepage = "https://kartat.hylly.org/";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
})
