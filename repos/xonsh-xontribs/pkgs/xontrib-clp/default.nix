{
  buildPythonPackage,
  lib,
  fetchFromGitHub,
  setuptools,
  wheel,
}:
buildPythonPackage {
  pname = "xontrib-clp";
  version = "0.1.6";
  src = fetchFromGitHub {
    owner = "anki-code";
    repo = "xontrib-clp";
    rev = "bd5c2b4fb245ca17291aef51b92476b71a9a07c8";
    sha256 = "sha256-2KrJgMw/M+rbMoAEqVaQ/1gAaBDsaPIcK3BpFtTgvRA=";
  };

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  meta = with lib; {
    homepage = "https://github.com/anki-code/xontrib-clp";
    description = "Copy output to clipboard (cross-platform) in the [xonsh shell](https://xon.sh).";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
  };
}
