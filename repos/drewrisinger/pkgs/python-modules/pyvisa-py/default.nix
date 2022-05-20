{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
# , gpib-ctypes # in v0.4+
, importlib-metadata
, pyusb
, pyvisa
, setuptools_scm
, toml
}:

buildPythonPackage rec {
  pname = "pyvisa-py";
  version = "0.5.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = "pyvisa-py";
    rev = version;
    sha256 = "sha256-WYQ0liqn8Xs2WtH1yuIdUmTWiBg8iKvUxxFdQMZKwHg=";
  };

  nativeBuildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [
    # gpib-ctypes
    pyusb
    pyvisa
    toml
  ] ++ lib.optionals (pythonOlder "3.8") [ importlib-metadata ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

  # Appears to try to run tests from pyvisa, but Nix file structure doesn't allow that
  doCheck = false;
  pythonImportsCheck = [
    "pyvisa_py"
    "pyvisa_py.usb"
    "pyvisa_py.tcpip"
    # "pyvisa_py.gpib"  # broken, but we don't care terribly much
  ];

  meta = with lib; {
    description = "A pure python PyVISA backend";
    homepage = "https://pyvisa-py.readthedocs.io";
    downloadPage = "https://github.com/pyvisa/pyvisa-py/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
