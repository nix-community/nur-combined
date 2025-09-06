{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "geotiler";
  version = "0.15.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wrobell";
    repo = "geotiler";
    tag = "geotiler-${version}";
    hash = "sha256-fiY5cJIus4eLzSfqVjZfmco4pFABYWNPVUOXGGYPEso=";
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
    pytest-asyncio
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
