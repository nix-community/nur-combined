{ stdenv, sources }:

stdenv.mkDerivation rec {
  pname = "mtk-suomi";
  version = sources.mtk-suomi.version;
  src = sources.mtk-suomi;

  preferLocalBuild = true;

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/gpxsee/maps/mtk_suomi.img
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
