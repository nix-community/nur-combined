{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "robobrowser";
  version = "0.5.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jmcarp";
    repo = "robobrowser";
    # rev = "v${version}";
    # fix: ImportError: cannot import name 'cached_property' from 'werkzeug'
    # https://github.com/jmcarp/robobrowser/pull/94
    rev = "9b5389b4999982677ac4b0dfad579310f03082df";
    hash = "sha256-1YjTL3gv6WbX4DmX83mA/NZAHCoN/2Gdu3YYonzOjjw=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    requests
    six
    werkzeug
    urllib3
  ];

  pythonImportsCheck = [
    "robobrowser"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/jmcarp/robobrowser";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "robobrowser";
  };
}
