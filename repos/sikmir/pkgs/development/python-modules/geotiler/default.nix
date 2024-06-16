{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "geotiler";
  version = "0.15.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wrobell";
    repo = "geotiler";
    rev = "geotiler-${version}";
    hash = "sha256-xqAsjuUMODZvkSMyGXpP1/FTyqNKPfa8l4Zr2CUHaDY=";
  };

  dependencies = with python3Packages; [
    aiohttp
    cytoolz
    numpy
    pillow
    setuptools
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov
  ];

  postInstall = ''
    cp -r geotiler/source $out/lib/${python3Packages.python.libPrefix}/site-packages/geotiler
  '';

  meta = {
    description = "GeoTiler is a library to create map using tiles from a map provider";
    homepage = "https://wrobell.dcmod.org/geotiler";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
