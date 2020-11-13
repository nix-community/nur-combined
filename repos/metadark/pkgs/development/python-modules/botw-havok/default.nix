{ lib
, buildPythonPackage
, isPy3k
, fetchFromGitHub
, colorama
, numpy
, oead
}:

buildPythonPackage rec {
  pname = "botw-havok";
  version = "0.3.17";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "krenyy";
    repo = "botw_havok";
    rev = "bec027faa2cc25d9bbc9af45cb30cf705d1c2d9e";
    sha256 = "03aad8cgzmhn8mgva77flhfna45pncacd4kb4s8x6bib70ksyp98";
  };

  patches = [
    ./loosen-requirements.patch
  ];

  propagatedBuildInputs = [
    colorama
    numpy
    oead
  ];

  # No tests
  doCheck = false;

  meta = with lib; {
    description = "A library for manipulating Breath of the Wild Havok packfiles";
    homepage = "https://github.com/krenyy/botw_havok";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
