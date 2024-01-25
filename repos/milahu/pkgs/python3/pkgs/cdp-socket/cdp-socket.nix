{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cdp-socket";
  version = "1.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaliiiiiiiiii";
    repo = "CDP-Socket";
    rev = "91882101aabac4cba5757a2f824b80d9300a64f2";
    hash = "sha256-/LJvhx44700x67bBw40Loi9vdKAtHai4PBwiAF+GGsU=";
  };

  # relax requirements
  # remove dev deps https://github.com/kaliiiiiiiiii/CDP-Socket/issues/23
  postPatch = ''
    sed -i 's/[=~><]=.*$//' requirements.txt
    sed -i 's/^twine$//; s/^setuptools$//' requirements.txt
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  # https://github.com/kaliiiiiiiiii/CDP-Socket/blob/master/requirements.txt
  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    websockets
    orjson
    #setuptools
    #twine
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
