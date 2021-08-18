{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "mtk-suomi";
  version = "2021-08-14";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${version}/mtk_suomi.img";
    hash = "sha256-UTGnzx8epdOOjSg8Qx73TPJlsJPfOZSEBYi5D0b2EFk=";
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
