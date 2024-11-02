{
  lib,
  sources,
  python3Packages,
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.onepush) pname version src;

  preBuild = ''
    # Override requests version
    echo "requests" > requirements.txt
  '';

  propagatedBuildInputs = [ requests ];
  doCheck = false;

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python library to send notifications to your iPhone, Discord, Telegram, WeChat, QQ and DingTalk";
    homepage = "https://gitlab.com/y1ndan/onepush";
    license = with lib.licenses; [ gpl3Only ];
  };
}
