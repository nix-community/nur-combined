{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  six,
}:

buildPythonPackage rec {
  pname = "bbpb";
  version = "1.4.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-A0RpkbxQDPyd0gSebMlImXnhV8Xst5PieTarPVedNJY=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    six
  ];

  pythonImportsCheck = [
    "blackboxprotobuf"
  ];

  meta = with lib; {
    description = "Library for working with protobuf messages without a protobuf type definition";
    homepage = "https://github.com/nccgroup/blackboxprotobuf";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "bbpb";
  };
}
