{ lib
, fetchFromGitHub
, python3
}:

let
  pname = "finplot";
  version = "1.7";
  owner = "highfestiva";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ixDCbMDMDf3ZPQcmQ1ap5vRetIm5vMgAirsFzJObTX4=";
  };

  propagatedBuildInputs = with python3.pkgs; [ pandas pyqt5 pyqtgraph ];

  pythonImportsCheck = [ "finplot" ];

  meta = with lib; {
    description = "Plot financial data";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
