{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, fetchpatch
, setuptools_scm
, typing-extensions
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pyvisa";
  version = "1.12.0";
  format = "pyproject";
  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "pyvisa";
    repo = pname;
    rev = version;
    sha256 = "sha256-2khTfj0RRna9YDPOs5kQHHhkeMwv3kTtGyDBYnu+Yhw=";
  };
  patches = [
    # setuptools < 61.0.0 (i.e. the one on nixos-21.05) can't process setuptools info in pyproject.toml vs setup.cfg. This reverts the upgrade
    (fetchpatch {
      name = "revert-update-to-full-experiment-pyproject-setup.patch";
      url = "https://github.com/pyvisa/pyvisa/commit/e060714aac16f7318d444fd2f8a01b18a7f1026a.patch";
      sha256 = "sha256-MWvgB/+UnQpX1pM8iqXQbgDqWzSIduHLAjr2iHTlUhA=";
      revert = true;
      excludes = [".github/*"];
    })
  ];

  nativeBuildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [ typing-extensions ];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

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
    changelog = "https://github.com/pyvisa/pyvisa/blob/main/CHANGES";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
