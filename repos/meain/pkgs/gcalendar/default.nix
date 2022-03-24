{ lib
, buildPythonPackage
, fetchFromGitHub
, oauth2client
, python-dateutil
, google-api-python-client
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "gcalendar";
  version = "182e5f754dc9e6886e9de83bd503df6d760c05bb";

  src = fetchFromGitHub {
    owner = "slgobinath";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-Nud/CYJeWUu1TDYrydLx8EUfI9qYO+Lst2zUlrmmPAI=";
  };

  propagatedBuildInputs = [
    oauth2client
    python-dateutil
    google-api-python-client
  ];

  checkInputs = [
    pytestCheckHook
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/gcalendar --help
  '';

  meta = with lib; {
    description = "Read-only Google Calendar utility for Linux ";
    homepage = "https://github.com/slgobinath/gcalendar";
    license = licenses.gpl3;
  };
}
