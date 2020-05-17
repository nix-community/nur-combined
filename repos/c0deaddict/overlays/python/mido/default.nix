{ lib
, buildPythonPackage
, fetchPypi
, setuptools_scm
, pytest
}:

buildPythonPackage rec {
  pname = "mido";
  version = "1.2.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1k3sgkxc7j49bapib3b5jnircb1yhyyd8mi0mbfd78zgix9db9y4";
  };

  checkInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  meta = with lib; {
    homepage = "https://pypi.org/project/testinfra/";
    description = "A library for working with MIDI messages and ports";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
