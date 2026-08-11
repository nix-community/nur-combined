{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "netgear-telnetenable";
  version = "unstable-2023-03-29";
  format = "setuptools";

  # https://github.com/insanid/netgear-telenetenable/pull/1
  src = fetchFromGitHub {
    owner = "milahu";
    repo = "netgear-telenetenable";
    rev = "132052641394bedadfd1bcd14c23197f0be409dc";
    hash = "sha256-PbDzpTeQtxPNdolEraPB7NPLzaRSqnJ3hNMvIktwojQ=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    cryptography
    getmac
  ];

  meta = with lib; {
    description = "Telenet Enable for Netgear routers";
    homepage = "https://github.com/insanid/netgear-telenetenable";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
