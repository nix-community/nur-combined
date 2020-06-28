{ lib
, buildPythonApplication
, fetchFromGitHub
, influxdb
, requests
}:

buildPythonApplication rec {
  pname = "solaredge-influx";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "solaredge-influx";
    rev = "v${version}";
    sha256 = "1i0zjxqzxmmy25bqjdymhs96w774sw07d5f7qd21lpnl3g9gky1p";
  };

  propagatedBuildInputs = [ influxdb requests ];

  doCheck = false;

  meta = with lib; {
    description = "Queries the Solaredge Monitoring API and stores the data in InfluxDB";
    homepage = "https://github.com/c0deaddict/solaredge-influx";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
