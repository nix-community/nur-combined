{ stdenv, sources }:

stdenv.mkDerivation {
  pname = "mtk-suomi";
  version = sources.mtk-suomi.version;
  src = sources.mtk-suomi;

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/gpxsee/maps/mtk_suomi.img
  '';

  meta = with stdenv.lib; {
    inherit (sources.mtk-suomi) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
