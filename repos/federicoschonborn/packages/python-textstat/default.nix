{ buildPythonPackage
, fetchPypi
, pyphen
, nix-update-script
}: buildPythonPackage rec {
  pname = "textstat";
  version = "0.7.3";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YLY8+JSfRbuztCBeRBG7wc1m30wIrvElRYEcfm4k8BE=";
  };

  propagatedBuildInputs = [
    pyphen
  ];

  pythonImportsCheck = [ "textstat" ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };
}
