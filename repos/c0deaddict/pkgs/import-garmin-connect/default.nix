{ lib
, buildPythonApplication
, fetchFromGitHub
, influxdb
, requests
}:

buildPythonApplication rec {
  pname = "import-garmin-connect";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "import-garmin-connect";
    rev = "v${version}";
    sha256 = "04dh8wvbhi3q5j2i9apvrl6xymwb0byd4ql2svf12sgm08wmhfn1";
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
