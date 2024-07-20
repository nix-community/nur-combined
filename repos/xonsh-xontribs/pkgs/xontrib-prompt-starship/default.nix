{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  lib,
}:
buildPythonPackage {
  pname = "xontrib-prompt-starship";
  version = "0.3.6";
  src = fetchFromGitHub {
    owner = "anki-code";
    repo = "xontrib-prompt-starship";
    rev = "d7603433bdb858ef8e38580247f099ac82d2660c";
    sha256 = "sha256-CLOvMa3L4XnH53H/k6/1W9URrPakPjbX1T1U43+eSR0=";
  };

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  meta = with lib; {
    homepage = "https://github.com/anki-code/xontrib-prompt-starship";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
    description = "Starship prompt in the [xonsh shell](https://xon.sh).";
  };
}
