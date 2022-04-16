{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy3k
, jsonpath-ng
, prometheus-client
, pyyaml
, requests
}:

buildPythonPackage rec {
  pname = "json_exporter";
  version = "0.2.3+4b0485c";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "catawiki";
    repo = "json_exporter";
    rev = "4b0485c8f1b284576c3d852402545a899e0dca85";
    sha256 = "1vjp9xs9drqksbw8sbdz2pss4yj1nl4spccqnmb0ri2n2ywxsfhn";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "jsonpath-ng==1.5.3" "jsonpath-ng>=1.5.2" \
      --replace "prometheus-client==0.12.0" "prometheus-client>=0.12.0" \
      --replace "requests==2.26.0" "requests>=2.26.0"
  '';

  propagatedBuildInputs = [
    jsonpath-ng
    prometheus-client
    pyyaml
    requests
  ];

  checkInputs = [
  ];

  pythonImportsCheck = [ "json_exporter" ];

  meta = with lib; {
    homepage = "https://github.com/catawiki/json_exporter";
    description = "Prometheus JSON exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ graham33 ];
  };
}
