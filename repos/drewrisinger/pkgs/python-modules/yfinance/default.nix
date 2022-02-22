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
  version = "0.1.70";

  src = fetchFromGitHub {
    owner = "ranaroussi";
    repo = pname;
    rev = version;
    sha256 = "sha256-Anvt+ag0PysGynQv4q+2IrQmCPZViGqWI4dgfLQWGds=";
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
      --replace "lxml>=4.5.1" "lxml" \
      --replace "requests>=2.26" "requests"
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
