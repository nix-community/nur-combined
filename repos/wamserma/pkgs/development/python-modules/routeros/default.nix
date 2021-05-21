{ lib
, fetchPypi
, buildPythonPackage
, ipdb
, nose
, poetry
, pytest
}:

buildPythonPackage rec {
  pname = "routeros";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "09asdwyn18xfvi0pblc4fp7lh9czkzns9kpx91dklqcs8xcfl54z";
  };

  buildInputs = [
    poetry
  ];

  checkInputs = [ pytest ipdb nose ];

  meta = with lib; {
    homepage = "https://github.com/rtician/routeros";
    description = "Implementation of Mikrotik API in Python";
    license = [ licenses.mit ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
