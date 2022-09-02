{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gaiagpsclient";
  version = "2021-06-22";

  src = fetchFromGitHub {
    owner = "kk7ds";
    repo = "gaiagpsclient";
    rev = "db3c8d197fa00d0bededa4ae96f06c39d7a85abc";
    hash = "sha256-yA3reda+ik3koHdb4OXDERfI01D7iEqgem8+XFn4YOM=";
  };

  propagatedBuildInputs = with python3Packages; [
    requests prettytable pytz tzlocal pyyaml pathvalidate
  ];

  checkInputs = with python3Packages; [ mock pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "A python client for gaiagps.com";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
  };
}
