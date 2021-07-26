{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "mtk-suomi";
  version = "2021-07-24";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${version}/mtk_suomi.img";
    hash = "sha256-TCuvw8nbIBfJi5M+BR4/pL9ciq86V4Xlb5Ak2kuYBA0=";
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
}
