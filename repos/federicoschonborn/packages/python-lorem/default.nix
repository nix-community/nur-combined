{ buildPythonPackage
, fetchPypi
, setuptools
, nix-update-script
}:

buildPythonPackage rec {
  pname = "python-lorem";
  version = "1.3.0.post1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aokLCuQq6iHpC90MLCcIQxeEArPyx1o6RU1224xZdxY=";
  };

  buildInputs = [
    setuptools
  ];

  pythonImportsCheck = [ "lorem" ];

  passthru.updateScript = nix-update-script { };
}
