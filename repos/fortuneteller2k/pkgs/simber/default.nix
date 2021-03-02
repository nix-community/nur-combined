{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "simber";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-k3ryTv9LfXpyhvDQf4TjR3BPzSr8oV0jbRnRpLN3A6k=";
  };

  buildInputs = [ colorama ];

  meta = with lib; {
    description = "A simple, minimal and powerful logging library for Python";
    homepage = "https://github.com/deepjyoti30/simber";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
