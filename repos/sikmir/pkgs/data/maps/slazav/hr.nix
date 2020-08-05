{ stdenv, cgpsmapper, gmaptool, imagemagick, mapsoft, netpbm, zip, sources }:
let
  pname = "slazav-hr";
  date = stdenv.lib.substring 0 10 sources.map-hr.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.map-hr;

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
    install -Dm644 hr.img -t $out
  '';

  meta = with stdenv.lib; {
    inherit (sources.map-hr) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
