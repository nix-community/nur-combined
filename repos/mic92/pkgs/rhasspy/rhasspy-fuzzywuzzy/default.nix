{ lib
, buildPythonPackage
, fetchPypi
, rapidfuzz
, rhasspy-nlu
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-fuzzywuzzy";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-cYhnDxnGfW1xHU+xWU6XrsLsmVbb2sQMLwpDy/9T2KI=";
  };

  postPatch = ''
    sed -i -e 's/rapidfuzz==.*/rapidfuzz/' requirements.txt
    sed -i "s/networkx==.*/networkx/" requirements.txt
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
