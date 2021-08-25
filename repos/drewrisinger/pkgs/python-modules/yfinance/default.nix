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
  version = "0.1.63";

  src = fetchFromGitHub {
    owner = "ranaroussi";
    repo = pname;
    rev = "6761b57f8b0be395d5337191fc8dfeebd01985fb"; # untagged :(
    sha256 = "1n763nwffgzgdhi4qdwg04r7sfwln574wzn7ydmphibz3dlykr9m";
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
