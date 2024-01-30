{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  nix-update-script,
}:
buildPythonPackage rec {
  pname = "darkdetect";
  version = "0.8.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tUKOEXAmPrXepEwl3DiV7ddeb1IwCYY1PNY1M/59+LE=";
  };

  buildInputs = [ setuptools ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://github.com/albertosottile/darkdetect";
    description = " Detect OS Dark Mode from Python";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
