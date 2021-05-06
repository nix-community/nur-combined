{ lib
, buildPythonApplication
, fetchFromGitHub
, influxdb
, requests
, setuptools_scm
}:

buildPythonApplication rec {
  pname = "import-garmin-connect";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "c0deaddict";
    repo = "import-garmin-connect";
    rev = "v${version}";
    sha256 = "1swmcg1rxvzsls8rdc85s063rjlgjc9k96jksm83sz068zqnz5a7";
  };

  buildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [ influxdb requests ];

  doCheck = false;

  meta = with lib; {
    description = "Import Garmin Connect data into InfluxDB";
    homepage = "https://github.com/c0deaddict/import-garmin-connect";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
