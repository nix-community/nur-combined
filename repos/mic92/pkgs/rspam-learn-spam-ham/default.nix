{ lib, fetchFromGitHub, buildPythonApplication, requests }:

buildPythonApplication rec {
  pname = "rspamd-learn-spam-ham";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "rspamd-learn-spam-ham";
    rev = version;
    sha256 = "0z9l49r2m7arapps026gz5pkshbfk1npvvmnsc1ig29ff73p63cm";
  };

  propagatedBuildInputs = [ requests ];

  meta = with lib; {
    description = "Teach rspamd about spam/non-spam based on read mails in your maildir";
    homepage = "https://github.com/Mic92/rspamd-learn-spam-ham";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
