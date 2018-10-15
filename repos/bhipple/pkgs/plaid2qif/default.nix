{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "plaid2qif";
  version = "1.3.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "0s2wah7wxwla9k04kh6q4v5rf51419ilv0a57xmh9vbsdbz2y0ia";
  };

  # TODO: See if we can fix setup.py instead.
  patchPhase = ''
    for dep in plaid-python wheel twine docopt python-dateutil; do
      echo $dep >> requirements.txt
    done
  '';

  propagatedBuildInputs = with python3Packages; [ plaid-python wheel twine docopt python-dateutil ];

  # No tests in archive
  doCheck = false;

  meta = {
    homepage = https://github.com/ebridges/plaid2qif;
    description = "Download financial transactions from Plaid as QIF files";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bhipple ];
  };
}
