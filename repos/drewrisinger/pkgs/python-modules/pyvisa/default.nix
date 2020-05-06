{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pyvisa";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = "pyvisa";
    rev = version;
    sha256 = "10cnkap8xj7r0s9lj5p04mxgrj3rfqysllrz973f8hy2sz66gmbk";
  };

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;

  meta = with lib; {
    description = "A python library with bindings to the VISA library.";
    longDescription = ''
      A Python package with bindings to the "Virtual Instrument Software Architecture" VISA library,
      in order to control measurement devices and test equipment via GPIB, RS232, or USB.
    '';
    homepage = "https://pyvisa.readthedocs.io";
    downloadPage = "https://github.com/pyvisa/pyvisa/releases";
    license = licenses.mit;
    maintainers = maintainers.drewrisinger;
  };
}

