{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "dyndnsc";
  version = "0.5.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1p8dgfhvks1bjvq8gww4yvi3g8fam2m5irirkf7xjhs8g38r8bjb";
  };

  nativeBuildInputs = with python3Packages; [ pytestrunner ];
  propagatedBuildInputs = with python3Packages; [
    daemonocle
    dnspython
    netifaces
    requests
    setuptools
  ];
  checkInputs = with python3Packages; [ bottle pytest ];

  postPatch = ''
    substituteInPlace setup.py --replace "bottle==" "bottle>="
  '';

  # Disable tests not supported in the sandbox.
  checkPhase = ''
    py.test -k 'not dnswanip'
  '';

  meta = with lib; {
    description = "Dynamic DNS update client with support for multiple protocols";
    homepage = "https://github.com/infothrill/python-dyndnsc";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.AluisioASG ];
  };
}
