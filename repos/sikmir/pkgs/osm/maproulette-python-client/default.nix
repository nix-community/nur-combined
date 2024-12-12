{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "maproulette-python-client";
  version = "1.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "osmlab";
    repo = "maproulette-python-client";
    tag = "v${version}";
    hash = "sha256-EmYa2B1FO4PNE1pdoPXeKo8uoY7Tc1cRwkqxiD41WrQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'setup_requires=["pytest-runner"],' ""
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ requests ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = {
    description = "A Python API wrapper for MapRoulette";
    homepage = "https://github.com/osmlab/maproulette-python-client";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
