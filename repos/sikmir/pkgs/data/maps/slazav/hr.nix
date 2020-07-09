{ stdenv, cgpsmapper, gmaptool, imagemagick, mapsoft, netpbm, zip, sources }:

stdenv.mkDerivation {
  pname = "slazav-hr";
  version = stdenv.lib.substring 0 7 sources.map_hr.rev;
  src = sources.map_hr;

  patches = [ ./0001-fix-hr.patch ];

  nativeBuildInputs = [
    cgpsmapper
    gmaptool
    imagemagick
    mapsoft
    netpbm
    zip
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/share/mapsoft" "${mapsoft}/share/mapsoft"
    substituteInPlace bin/map_update_index.sh \
      --replace "/usr/share/mapsoft" "${mapsoft}/share/mapsoft"

    patchShebangs ./bin
  '';

  dontConfigure = true;

  preBuild = "mkdir -p OUT";

  buildFlags = [ "out" "img" ];

  installPhase = ''
    install -Dm644 hr.img -t $out/share/gpxsee/maps
  '';

  meta = with stdenv.lib; {
    inherit (sources.map_hr) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
