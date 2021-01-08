{ lib
, buildPythonApplication
, fetchFromGitHub
, influxdb
, requests
}:

buildPythonApplication rec {
  pname = "import-garmin-connect";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "import-garmin-connect";
    rev = "v${version}";
    sha256 = "0s9fwlazdkdwxlf0w85pshswixs09jam5j3gaivn458m3lz1iv7h";
  };

  propagatedBuildInputs = [ influxdb requests ];

  doCheck = false;

  meta = with lib; {
    description = "Import Garmin Connect data into InfluxDB";
    homepage = "https://github.com/c0deaddict/import-garmin-connect";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
