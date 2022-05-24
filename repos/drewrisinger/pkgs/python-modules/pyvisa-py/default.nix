{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, fetchpatch
# , gpib-ctypes # in v0.4+
, importlib-metadata
, pyusb
, pyvisa
, setuptools_scm
, toml
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pyvisa-py";
  version = "0.5.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = "pyvisa-py";
    rev = version;
    sha256 = "sha256-37GptqqBSIFOpm6SpS61ZZ9C4iU5AiOduVq255mTRNo=";
  };

  patches = [

    # upstream converted to using pyproject in this release, but that's not backwards-compatible. Mostly reverts the patch from https://github.com/pyvisa/pyvisa-py/commit/dd8e9041bb9d22fb991c8be6cc61c1005990c75f
    ./0001-convert-pyproject-setup-to-setupcfg.patch
  ];

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

  checkInputs = [ pytestCheckHook ];
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
