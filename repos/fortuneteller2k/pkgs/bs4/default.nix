{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "bs4";
  version = "0.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-NuzqH9fMXAxuSh/wdd8m1Q2mR7dTdmJswYbiISiG3To=";
  };

  buildInputs = [ beautifulsoup4 ];

  meta = with lib; {
    description = "HTML and XML parser (dummy package)";
    homepage = "https://www.crummy.com/software/BeautifulSoup/bs4/";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
