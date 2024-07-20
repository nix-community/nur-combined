{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  lib,
}:
buildPythonPackage {
  pname = "xontrib-sh";
  version = "0.3.1";
  src = fetchFromGitHub {
    owner = "anki-code";
    repo = "xontrib-sh";
    rev = "a8f54908d001336cf7580f36233aa8f00978b479";
    sha256 = "sha256-KL/AxcsvjxqxvjDlf1axitgME3T+iyuW6OFb1foRzN8=";
  };

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  meta = with lib; {
    homepage = "https://github.com/anki-code/xontrib-sh";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
    description = "Paste and run commands from bash, fish, zsh, tcsh in the [xonsh shell](https://xon.sh).";
  };
}
