{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  maprec,
}:

python3Packages.buildPythonPackage {
  pname = "ozi-map";
  version = "0-unstable-2025-01-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "ozi_map";
    rev = "e45c55ca9dd3a7082fe60048a304e5d48d5c2cad";
    hash = "sha256-cfe1mCwbHDl3CN3dMtG6CF+oK4gDHnjjho2OgHWiYew=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail " @ git+https://github.com/wladich/maprec.git" ""
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    maprec
    pyproj
  ];

  doCheck = false;

  pythonImportsCheck = [ "ozi_map" ];

  meta = {
    description = "Python module for reading OziExplorer .map files";
    homepage = "https://github.com/wladich/ozi_map";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
