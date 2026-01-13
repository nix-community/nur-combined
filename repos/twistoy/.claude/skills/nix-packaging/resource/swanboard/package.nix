{ lib, buildPythonPackage, pythonOlder, fetchFromGitHub, pytestCheckHook
, hatchling, hatch-fancy-pypi-readme, hatch-requirements-txt, swankit, fastapi
, uvicorn, peewee, ujson, psutil, pyyaml, setuptools, nanoid, numpy }:

# TODO(breakds): Build the UI. It seemed pretty straight forward but
# for some reason I will run into this "dead spiral" of fetchYarnDeps
# always complain about a changed yarn.lock (and hash).
buildPythonPackage rec {
  pname = "swanboard";
  version = "0.1.7-beta.1";
  format = "pyproject";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "SwanHubX";
    repo = "SwanLab-Dashboard";
    rev = "v${version}";
    hash = "sha256-jBYlBJaEZPJ2tORfeSUnTpwyAjENh8QYTfVb6o2UNZg=";
  };

  build-system =
    [ hatchling hatch-fancy-pypi-readme hatch-requirements-txt setuptools ];

  dependencies = [ swankit fastapi uvicorn peewee ujson psutil pyyaml ];

  pythonImportsCheck = [ "swanboard" ];

  nativeCheckInputs = [ pytestCheckHook nanoid numpy ];

  disabledTests = [
    "test_get_package_version_installed"
    "test_get_package_version_not_installed"
    # Temporarily disable because there is a small bug that needs to be fixed.
    "TestExperiment"
  ];

  meta = with lib; {
    description = "Swanlab's Dashboard";
    homepage = "https://github.com/SwanHubX/SwanLab-Dashboard";
    license = licenses.asl20;
    maintainers = with maintainers; [ breakds ];
  };
}
