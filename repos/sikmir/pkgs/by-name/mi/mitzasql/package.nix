{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "mitzasql";
  version = "1.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vladbalmos";
    repo = "mitzasql";
    tag = version;
    hash = "sha256-C/KecK8PJDn/MyUxtxFLjVnkra6pW9QoLY34FWkwQ+8=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    appdirs
    pygments
    mysql-connector
    urwid
  ];

  pythonRelaxDeps = true;

  doCheck = false; # MySQL server required

  meta = {
    description = "MySQL command line / text based interface client";
    homepage = "https://vladbalmos.github.io/mitzasql/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
