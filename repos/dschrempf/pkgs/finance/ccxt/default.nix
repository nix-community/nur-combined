{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "ccxt";
  version = "4.4.68";
  owner = pname;
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-y/uECYct1t3WjFVnOjsURPIB6dW6p0sPmuEz/JLCwMw=";
  };

  prePatch = "cd python";

  nativeBuildInputs = with python3.pkgs; [
    aiodns
    certifi
    yarl
  ];
  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    cryptography
    requests
  ];

  doCheck = false;
  pythonImportsCheck = [ pname ];

  meta = with lib; {
    description = "Cryptocurrency exchange trading library";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
