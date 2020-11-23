{ lib, python3Packages, sources
, gobject-introspection, pango
, maprec, ozi_map, pyimagequant }:

python3Packages.buildPythonApplication {
  pname = "map-tiler";
  version = lib.substring 0 10 sources.map-tiler.date;

  src = sources.map-tiler;

  patches = [
    ./gobject.patch
    ./python3.patch
  ];

  postPatch = ''
    2to3 -n -w *.py lib/*.py
    substituteInPlace tiles_update.py \
      --replace "from . import image_store" "import image_store" \
      --replace "from .lib" "from lib"
  '';

  nativeBuildInputs = [ gobject-introspection pango ];

  pythonPath = with python3Packages; [
    pillow purepng
    pygobject3 pycairo
    maprec ozi_map pyimagequant
  ];

  dontUseSetuptoolsBuild = true;

  doCheck = false;

  installPhase = ''
    site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
    mkdir -p $site_packages
    cp -r *.py lib $site_packages

    buildPythonPath "$out $pythonPath"
    makeWrapper $site_packages/tiles_update.py $out/bin/tiles_update \
      --set PYTHONPATH $site_packages:$program_PYTHONPATH \
      --set GI_TYPELIB_PATH $GI_TYPELIB_PATH
  '';

  meta = with lib; {
    inherit (sources.map-tiler) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
