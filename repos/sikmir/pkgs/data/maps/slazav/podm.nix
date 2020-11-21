{ stdenv, cgpsmapper, gmaptool, imagemagick, mapsoft, netpbm, zip, sources }:

stdenv.mkDerivation {
  pname = "slazav-podm-unstable";
  version = stdenv.lib.substring 0 10 sources.map-podm.date;

  src = sources.map-podm;

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

  installPhase = "install -Dm644 podm.img -t $out";

  meta = with stdenv.lib; {
    inherit (sources.map-podm) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
