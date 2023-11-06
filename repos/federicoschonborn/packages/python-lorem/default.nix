{ buildPythonPackage
, fetchPypi
, nix-update-script
}: buildPythonPackage rec {
  pname = "python-lorem";
  version = "1.3.0.post1";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aokLCuQq6iHpC90MLCcIQxeEArPyx1o6RU1224xZdxY=";
  };

  pythonImportsCheck = [ "lorem" ];

  passthru.updateScript = nix-update-script { };
}
