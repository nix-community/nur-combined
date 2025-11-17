{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "systemdlint";
  version = "1.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "priv-kweihmann";
    repo = "systemdlint";
    tag = version;
    hash = "sha256-cJpZkqj4IWxofFWju/s8K3JoCVigSQHpN3o1+rG1/iM=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    systemdunitparser
    anytree
  ];

  meta = {
    description = "Systemd Unitfile Linter";
    homepage = "https://github.com/priv-kweihmann/systemdlint";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "systemdlint";
  };
}
