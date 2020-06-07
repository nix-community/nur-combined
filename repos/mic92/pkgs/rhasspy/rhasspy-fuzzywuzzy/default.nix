{ lib
, buildPythonPackage
, fetchPypi
, rapidfuzz
, rhasspy-nlu
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-fuzzywuzzy";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "c0445c6c963754987e23e36e35cc83a8be09348759c7f26b2019d93cdf596dda";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-fuzzywuzzy/commit/f29fd282df4253e75209e7ae260749c4bddb8ae7.patch";
      sha256 = "1i7fi51qdkjsjq1cy11ca6w1k671ww4fk7pr520xdlc4gcxi5hcf";
    })
  ];

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
