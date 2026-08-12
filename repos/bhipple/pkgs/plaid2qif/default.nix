{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "plaid2qif";
  version = "unstable";

  src = /home/bhipple/git/plaid2qif;
  # src = python3Packages.fetchPypi {
  #   inherit pname version;
  #   sha256 = "07f76bhhlj4zdv68i4nk1pvx745r9i6qgzkwv029d97djw4mj9gf";
  # };

  propagatedBuildInputs = with python3Packages; [
    docopt
    plaid-python
    python-dateutil
    python-dotenv
    setuptools
  ];

  # No tests in archive
  doCheck = false;

  meta = {
    homepage = "https://github.com/ebridges/plaid2qif";
    description = "Download financial transactions from Plaid as QIF files";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bhipple ];
  };
}
