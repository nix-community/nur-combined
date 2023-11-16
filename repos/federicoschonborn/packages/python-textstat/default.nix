{ buildPythonPackage
, fetchPypi
, setuptools
, pyphen
, nix-update-script
}:

buildPythonPackage rec {
  pname = "textstat";
  version = "0.7.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
  };

  buildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    pyphen
  ];

  pythonImportsCheck = [ "textstat" ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };
}
