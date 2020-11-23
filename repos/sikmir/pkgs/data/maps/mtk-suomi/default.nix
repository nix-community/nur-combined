{ stdenvNoCC, lib, sources }:

stdenvNoCC.mkDerivation {
  pname = "mtk-suomi";
  version = sources.mtk-suomi.version;

  src = sources.mtk-suomi;

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = "install -Dm644 $src $out/mtk_suomi.img";

  meta = with lib; {
    inherit (sources.mtk-suomi) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
