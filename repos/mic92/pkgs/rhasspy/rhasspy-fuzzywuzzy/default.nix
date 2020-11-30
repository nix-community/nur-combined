{ lib
, buildPythonPackage
, fetchPypi
, rapidfuzz
, rhasspy-nlu
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-fuzzywuzzy";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-CiTA/JkwiOHH9xF0Tvnm4gbNbYoCd+jYatpI9ObMhh0=";
  };

  postPatch = ''
    sed -i -e 's/rapidfuzz==.*/rapidfuzz/' requirements.txt
  '';

  propagatedBuildInputs = [
    rapidfuzz
    rhasspy-nlu
  ];

  doCheck = false;

  meta = with lib; {
    description = "Intent recognition library for Rhasspy using fuzzywuzzy";
    homepage = "https://github.com/rhasspy/rhasspy-fuzzywuzzy";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
