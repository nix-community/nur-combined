{ lib
, fetchFromGitHub
, python3
, qtbase
, wrapQtAppsHook
}:

let
  pname = "finplot";
  # WTNG: Numpy is blocking update to 1.8.2.
  version = "1.8";
  owner = "highfestiva";
in
python3.pkgs.buildPythonPackage rec {
  inherit pname;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-MzS9ogRysx50DDHnV/tSKrm6xG3f3n746oSienX5mX4=";
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
