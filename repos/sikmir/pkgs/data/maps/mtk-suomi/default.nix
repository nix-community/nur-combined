{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "mtk-suomi";
  version = "2021-04-16";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${version}/mtk_suomi.img";
    sha256 = "01kfb4h22z0c3qisgjwwf546i086gw8jfs1c52yc8agkal16fi46";
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
