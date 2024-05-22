{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "gaiagpsclient";
  version = "0-unstable-2023-08-26";

  src = fetchFromGitHub {
    owner = "kk7ds";
    repo = "gaiagpsclient";
    rev = "1ba0ea4266260ff979c7df483381d01d29fae25d";
    hash = "sha256-qCpyJfa8TeMfawf1+wCFu04sYHfDejyStNl6Q6XEUeA=";
  };

  propagatedBuildInputs = with python3Packages; [
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

  meta = with lib; {
    description = "A python client for gaiagps.com";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    mainProgram = "gaiagps";
  };
}
