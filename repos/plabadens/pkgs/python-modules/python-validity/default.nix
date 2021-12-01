{ lib
, buildPythonApplication
, fetchFromGitHub

, cryptography
, pyusb
, pyyaml
}:

buildPythonApplication rec {
  pname = "python-validity";
  version = "2021-09-26";

  src = fetchFromGitHub {
    owner = "uunicorn";
    repo = pname;
    rev = "c94c243bce6a1f8451cbb2b39299f21d3832bf5f";
    hash = "sha256-SJY/dlebgBE7vYE4E+3fOiGneLsxfDULruBxF26AlBA=";
  };

  propagatedBuildInputs = [ cryptography pyusb pyyaml ];

  doCheck = true;

  meta = with lib; {
    description = "Validity fingerprint sensor prototype";
    homepage = "https://github.com/uunicorn/python-validity";
    license = licenses.mit;
  };
}
