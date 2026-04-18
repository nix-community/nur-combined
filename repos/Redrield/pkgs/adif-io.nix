{ python3Packages, fetchPypi, lib }:
python3Packages.buildPythonPackage rec {
  pname = "adif_io";
  version = "0.6.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CmUtWb1U8/AF21yPCnwLVhqH35ZSakspKRhxoTnH9xU=";
  };

  build-system = with python3Packages; [ setuptools ];

}
