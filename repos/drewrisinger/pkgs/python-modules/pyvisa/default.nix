{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, setuptools_scm
, typing-extensions
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pyvisa";
  version = "1.11.3";
  format = "pyproject";
  disabled = pythonOlder "3.6";

  src = fetchPypi {
    pname = "PyVISA";
    inherit version;
    sha256 = "00v7v31jhihy1hz8l629yl8hakymidafbpgw4q4s1qgw94fn0jzv";
  };

  nativeBuildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [ typing-extensions ];

  checkInputs = [ pytestCheckHook ];
  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  meta = with lib; {
    description = "A python library with bindings to the VISA library.";
    longDescription = ''
      A Python package with bindings to the "Virtual Instrument Software Architecture" VISA library,
      in order to control measurement devices and test equipment via GPIB, RS232, or USB.
    '';
    homepage = "https://pyvisa.readthedocs.io";
    downloadPage = "https://github.com/pyvisa/pyvisa/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
