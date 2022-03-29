{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "mtk-suomi";
  version = "2022-03-15";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${version}/mtk_suomi.img";
    hash = "sha256-s5pk+CvbrWQfC4SGQwGtDY8gg0K5ilZbYOC2lB+c7I8=";
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
