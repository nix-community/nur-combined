{ buildPythonPackage
, fetchPypi
, beets-unstable
, requests
, lib
}:

buildPythonPackage rec {
  pname = "beets-yearfixer";
  version = "0.0.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "6b70658cde22c8c5c58fa182f9c50d9cb0ab7e5877e2d5e873058d0369548ff4";
  };
  propagatedBuildInputs = [
    beets-unstable
    requests
  ];
  doCheck = false;
  meta = {
    description = "The beets-yearfixer plugin finds the original_year for each of your songs by querying the MusicBrainz database and finding the first release date that is associated with it.";
    homepage = "https://github.com/adamjakab/BeetsPluginYearFixer";
    license = lib.licenses.mit;
  };
}
