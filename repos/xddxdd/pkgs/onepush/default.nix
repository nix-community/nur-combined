{ lib
, fetchFromGitLab
, python3Packages
, ...
} @ args:

with python3Packages;

buildPythonPackage rec {
  pname = "onepush";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "y1ndan";
    repo = pname;
    rev = version;
    sha256 = "sha256-lISVk+fOP3qKtWNtGiMNZ/F9fuxnlA6IfjPMWTgtK84=";
  };

  preBuild = ''
    # Override requests version
    echo "requests" > requirements.txt
  '';

  propagatedBuildInputs = [ requests ];
  doCheck = false;

  meta = with lib; {
    description = "A Python library to send notifications to your iPhone, Discord, Telegram, WeChat, QQ and DingTalk.";
    homepage = "https://gitlab.com/y1ndan/onepush";
    license = with licenses; [ gpl3Only ];
  };
}
