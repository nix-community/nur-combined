{ lib, stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "mtk-suomi";
  version = "2022-01-29";

  src = fetchurl {
    url = "https://kartat-dl.hylly.org/${version}/mtk_suomi.img";
    hash = "sha256-SjN5RP+aOZN5hiMdEzWENhd/3XTc18SJTvgYka4oRTU=";
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
