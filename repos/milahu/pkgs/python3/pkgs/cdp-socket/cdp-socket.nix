{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cdp-socket";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "CDP-Socket";
    rev = "df8ca70a5d1960fe792ab9ddd9f71b53a44187cf";
    hash = "sha256-wBmgg/qp7VA3cSLP4wjhMlMtWj9IXry7c+pntzW+yzQ=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    setuptools
    twine
    websockets
  ];

  pythonImportsCheck = [ "cdp_socket" ];

  meta = with lib; {
    description = "Socket for handling chrome-developer-protocol connections";
    homepage = "https://github.com/kaliiiiiiiiii/CDP-Socket";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "cdp-socket";
  };
}
