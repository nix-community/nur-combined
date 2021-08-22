{ lib
, fetchFromGitHub
, python3 }:

python3.pkgs.buildPythonPackage rec {
  pname = "alpha_vantage";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "RomelTorres";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-x8zqeMVjaMGx++sK6641JfzbM9s0D982vi4SCNWKE8o=";
  };

  meta = with lib; {
    description = "Python interface to free AlphaVantage stock data API";
    homepage = "https://github.com/RomelTorres/alpha_vantage";
    license = licenses.mit;
    maintainers = with maintainers; [ dschrempf ];
  };
}
