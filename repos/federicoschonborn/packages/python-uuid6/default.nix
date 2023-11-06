{ buildPythonPackage
, fetchPypi
, nix-update-script
}: buildPythonPackage rec {
  pname = "uuid6";
  version = "2023.5.2";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-A8uX8lynsKxL6is6IF9mv+f1jTsXm7D3bh15RkRrYTM=";
  };

  pythonImportsCheck = [ "uuid6" ];

  passthru.updateScript = nix-update-script { };
}
