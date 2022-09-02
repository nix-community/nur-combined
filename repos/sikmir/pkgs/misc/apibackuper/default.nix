{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "apibackuper";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "ruarxive";
    repo = "apibackuper";
    rev = version;
    hash = "sha256-2vNuzQK6Wm6DBWRSLFuy6loCLAbcql3CqSktMjGE8JE=";
  };

  propagatedBuildInputs = with python3Packages; [ bson click lxml requests xmltodict ];

  doCheck = false;

  meta = with lib; {
    description = "Python library and cmd tool to backup API calls";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
