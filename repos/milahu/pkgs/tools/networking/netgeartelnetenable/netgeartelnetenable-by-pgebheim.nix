{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "netgeartelnetenable-by-pgebheim";
  version = "unstable-2023-03-29";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "netgear-telenetenable";
    rev = "62e72084355aeef98faf9c6201bd49262b542139";
    hash = "sha256-C1ZS+tCpvZPOKwBf5iBr9FJOEut80xayc3pBVJaC96Q=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    cryptography
    getmac
  ];

  meta = with lib; {
    description = "Telenet Enable for Netgear routers";
    homepage = "https://github.com/milahu/netgear-telenetenable";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
