{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "pymbtiles";
  version = "0.5.0-unstable-2021-02-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "consbio";
    repo = "pymbtiles";
    rev = "5094f77de6fb920092952df68aa64f91bf2aa097";
    hash = "sha256-aBp3ocXkHsb9vimvhgOn2wgfTM0GMuA4mTcqeFsLQzc=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Python utilities for Mapbox mbtiles files";
    homepage = "https://github.com/consbio/pymbtiles";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
