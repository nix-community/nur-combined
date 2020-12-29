{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "plaid2qif";
  version = "1.3.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "07f76bhhlj4zdv68i4nk1pvx745r9i6qgzkwv029d97djw4mj9gf";
  };

  # TODO: See if we can fix setup.py instead.
  patchPhase = ''
    rm -f requirements.txt
    for dep in plaid-python wheel twine docopt python-dateutil; do
      echo $dep >> requirements.txt
    done
  '';

  propagatedBuildInputs = with python3Packages; [
    docopt
    plaid-python
    python-dateutil
    twine
    wheel
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
