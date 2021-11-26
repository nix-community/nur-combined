{ lib
, buildPythonPackage
, fetchFromGitHub
, lxml
, multitasking
, numpy
, pandas
, requests
  # Check Inputs
, python
}:

buildPythonPackage rec {
  pname = "yfinance";
  version = "0.1.67";

  src = fetchFromGitHub {
    owner = "ranaroussi";
    repo = pname;
    rev = version;
    sha256 = "163869cxs4mv7qmzjnvca95y746ggfh3xc7ha85ih455fy2r41a3";
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
  doCheck = false;  # requires network
  pythonImportsCheck = [ "yfinance" ];
  checkPhase = ''
    ${python.interpreter} ./test_yfinance.py
  '';

  meta = with lib; {
    description = "Yahoo! Finance market data downloader (+faster Pandas Datareader)";
    homepage = "https://aroussi.com/post/python-yahoo-finance";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
