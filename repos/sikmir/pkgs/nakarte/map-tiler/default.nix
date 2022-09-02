{ lib
, stdenv
, python3Packages
, fetchFromGitHub
, gobject-introspection
, pango
, maprec
, ozi_map
, pyimagequant
}:

python3Packages.buildPythonApplication rec {
  pname = "map-tiler";
  version = "2019-10-24";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "map-tiler";
    rev = "1dc5be65e58638f5899cd6cdc2010e00ce5e62d4";
    hash = "sha256-2wDhU1wbvyEAAYUQXUGASmK5X0/XNQF9P2y9pfHhHHg=";
  };

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
    pillow
    purepng
    pygobject3
    pycairo
    maprec
    ozi_map
    pyimagequant
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
    description = "Raster maps to map tiles";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    broken = stdenv.isDarwin;
  };
}
