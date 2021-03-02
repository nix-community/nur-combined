{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "itunespy";
  version = "1.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-baENY+iglfcXIwv9m8h0eYcj/iyR/vtgiQ0bJxrMzUU=";
  };

  buildInputs = [ pycountry requests ];

  meta = with lib; {
    description =
      "A simple library to fetch data from the iTunes Store API made for Python >= 3.5";
    homepage = "https://github.com/sleepyfran/itunespy";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
