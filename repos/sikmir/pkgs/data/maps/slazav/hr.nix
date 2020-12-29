{ stdenv, bc, cgpsmapper, gmaptool, mapsoft2, sources }:

stdenv.mkDerivation {
  pname = "slazav-hr-unstable";
  version = stdenv.lib.substring 0 10 sources.map-hr.date;

  src = sources.map-hr;

  nativeBuildInputs = [ bc cgpsmapper gmaptool mapsoft2 ];

  buildFlags = [ "directories" "reg_img" ];

  installPhase = "install -Dm644 OUT/all_*.img -t $out";

  meta = with stdenv.lib; {
    inherit (sources.map-hr) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
