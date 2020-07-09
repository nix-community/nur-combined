{ stdenv, cgpsmapper, gmaptool, imagemagick, mapsoft, netpbm, zip, sources }:

stdenv.mkDerivation {
  pname = "slazav-podm";
  version = stdenv.lib.substring 0 7 sources.map_podm.rev;
  src = sources.map_podm;

  patches = [ ./0001-fix-podm.patch ];

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

    patchShebangs ./bin
  '';

  dontConfigure = true;

  preBuild = "mkdir -p OUT";

  buildFlags = [ "out" "img" ];

  installPhase = ''
    install -Dm644 podm.img -t $out/share/gpxsee/maps
  '';

  meta = with stdenv.lib; {
    inherit (sources.map_podm) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
