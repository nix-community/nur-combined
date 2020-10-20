{ lib
, buildPythonPackage
, fetchFromGitHub
, lxml
, multitasking
, numpy
, pandas
, requests
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "yfinance";
  version = "0.1.55";

  src = fetchFromGitHub {
    owner = "ranaroussi";
    repo = pname;
    rev = version;
    sha256 = "0484jsi526gdas0k1i50fapl4wi272jfgskw480h6m78xs8asz4q";
  };

  propagatedBuildInputs = [
    lxml
    multitasking
    numpy
    pandas
    requests
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "lxml>=4.5.1" "lxml"
  '';

  # Tests
  doCheck = false;
  pythonImportsCheck = [ "yfinance" ];

  meta = with lib; {
    description = "Yahoo! Finance market data downloader (+faster Pandas Datareader)";
    homepage = "https://aroussi.com/post/python-yahoo-finance";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
