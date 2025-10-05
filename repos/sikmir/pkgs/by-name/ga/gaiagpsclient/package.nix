{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gaiagpsclient";
  version = "0-unstable-2023-08-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kk7ds";
    repo = "gaiagpsclient";
    rev = "1ba0ea4266260ff979c7df483381d01d29fae25d";
    hash = "sha256-qCpyJfa8TeMfawf1+wCFu04sYHfDejyStNl6Q6XEUeA=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    prettytable
    pytz
    tzlocal
    pyyaml
    pathvalidate
  ];

  nativeCheckInputs = with python3Packages; [
    mock
    pytestCheckHook
  ];

  doCheck = false;

  meta = {
    description = "A python client for gaiagps.com";
    homepage = "https://github.com/kk7ds/gaiagpsclient";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "gaiagps";
  };
}
