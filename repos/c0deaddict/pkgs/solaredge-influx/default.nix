{ lib
, buildPythonApplication
, fetchFromGitHub
, influxdb
, requests
}:

buildPythonApplication rec {
  pname = "solaredge-influx";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "solaredge-influx";
    rev = "v${version}";
    sha256 = "0s82ll8vys6wmh50vxxklnb66fnib5y6sd2bknkwi9smrv6ycfi0";
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
