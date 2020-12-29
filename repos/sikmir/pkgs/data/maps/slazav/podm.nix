{ stdenv, bc, cgpsmapper, gmaptool, mapsoft2, sources }:

stdenv.mkDerivation {
  pname = "slazav-podm-unstable";
  version = stdenv.lib.substring 0 10 sources.map-podm.date;

  src = sources.map-podm;

  nativeBuildInputs = [ bc cgpsmapper gmaptool mapsoft2 ];

  buildFlags = [ "directories" "reg_img" ];

  installPhase = "install -Dm644 OUT/all_*.img -t $out";

  meta = with stdenv.lib; {
    inherit (sources.map-podm) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
