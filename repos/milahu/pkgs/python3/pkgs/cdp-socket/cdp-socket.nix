{ lib
, python3
, fetchFromGitHub
, fetchurl
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cdp-socket";
  version = "1.2.4";
  pyproject = true;

  src =
  if true then
  fetchurl {
    url = "https://github.com/kaliiiiiiiiii/CDP-Socket/archive/4813479d7b856c4a609aa19e6fea80ed9d425445.zip";
    hash = "sha256-XrjpwV361ArJehY53cRwlGEyX/Cru5Eg+Ys1NCcYWbQ=";
  }
  else
  fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "CDP-Socket";
    rev = "91882101aabac4cba5757a2f824b80d9300a64f2";
    hash = "sha256-/LJvhx44700x67bBw40Loi9vdKAtHai4PBwiAF+GGsU=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  # https://github.com/kaliiiiiiiiii/CDP-Socket/blob/master/setup.py
  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    websockets
    orjson
  ];

  pythonImportsCheck = [ "cdp_socket" ];

  meta = with lib; {
    description = "Socket for handling chrome-developer-protocol connections";
    homepage = "https://github.com/kaliiiiiiiiii/CDP-Socket";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "cdp-socket";
  };
}
