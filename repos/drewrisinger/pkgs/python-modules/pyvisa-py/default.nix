{ lib
, buildPythonPackage
, fetchFromGitHub
# , gpib-ctypes # in v0.4+
, pyusb
, pyvisa
}:

buildPythonPackage rec {
  pname = "pyvisa-py";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = "pyvisa-py";
    rev = version;
    sha256 = "1b5jn8zaxz3fs8vphdvakx19xp4659ihnmndf0zyc6f51bdx46d9";
  };

  propagatedBuildInputs = [
    # gpib-ctypes
    pyusb
    pyvisa
  ];

  # Appears to try to run tests from pyvisa, but Nix file structure doesn't allow that
  doCheck = false;
  pythonImportsCheck = [
    "pyvisa-py"
    "pyvisa-py.usb"
    "pyvisa-py.tcpip"
    # "pyvisa-py.gpib"  # broken, but we don't care terribly much
  ];

  meta = with lib; {
    description = "A pure python PyVISA backend";
    homepage = "https://pyvisa-py.readthedocs.io";
    downloadPage = "https://github.com/pyvisa/pyvisa-py/releases";
    license = licenses.mit;
    maintainers = maintainers.drewrisinger;
  };
}