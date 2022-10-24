{ lib
, fetchFromGitHub
, python3
, qtbase
, wrapQtAppsHook
}:

let
  pname = "finplot";
  version = "1.8.4";
  owner = "highfestiva";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-jXIN3iKGA4cViKxRC6rrBMte5A1FVHCfyf0rXJA3m9Q=";
  };

  nativeBuildInputs = [ wrapQtAppsHook ];
  buildInputs = [ qtbase ];
  propagatedBuildInputs = with python3.pkgs; [ pandas pyqt5 pyqtgraph ];

  pythonImportsCheck = [ "finplot" ];

  meta = with lib; {
    description = "Plot financial data";
    homepage = "https://github.com/${owner}/${pname}";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
