{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  # exiv2 would be python3Packages.exiv2
  pkgs-exiv2,
  pybind11,
}:

let exiv2 = pkgs-exiv2; in

buildPythonPackage (finalAttrs: {
  pname = "pyexiv2";
  version = "2.15.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LeoHsiao1";
    repo = "pyexiv2";
    # tag = "v${finalAttrs.version}";
    # https://github.com/LeoHsiao1/pyexiv2/pull/175
    rev = "42bf5699fc548aaf8bf53019c9e76e5061658606";
    hash = "sha256-OMh+f3dUTF/1zlqCZ9xrhOlAFg/SLY87ubs21mG4HCo=";
  };

  postPatch = ''
    substituteInPlace pyexiv2/lib/__init__.py \
      --replace \
        'lib_dir     = os.path.dirname(__file__)' \
        'lib_dir = "${exiv2.lib}/lib"'
  '';

  build-system = [
    setuptools
  ];

  buildInputs = [
    exiv2
    pybind11
  ];

  pythonImportsCheck = [
    "pyexiv2"
  ];

  meta = {
    description = "A Python library for reading and writing image metadata, including EXIF, IPTC, XMP, ICC Profile";
    homepage = "https://github.com/LeoHsiao1/pyexiv2";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
