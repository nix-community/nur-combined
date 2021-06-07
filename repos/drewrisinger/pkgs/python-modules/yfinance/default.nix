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
    rev = "eb42fbfbcd5beca3f08b1eb0dce59b6e531bb211"; # untagged :(
    sha256 = "010ws97vlj2dvbdnzf1xmlmicgdbmkkhpf2n948wcfsczyd7v5kh";
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
