{ lib
, bidict
, buildPythonPackage
, fetchFromGitHub
, mock
, pytestCheckHook
, python-engineio_3
}:

buildPythonPackage rec {
  pname = "python-socketio";
  version = "4.7.0-preb5f4bb9";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = "python-socketio";
    rev = "b5f4bb9013226d41314085db044bdea9fb8c4b1d";
    sha256 = "sha256-L5A/MAb9XIcW2YlCtic6B5yP85hRrrjkDFeldGDxvOs=";
  };

  propagatedBuildInputs = [
    bidict
    python-engineio_3
  ];

  checkInputs = [
    mock
    pytestCheckHook
  ];

  pythonImportsCheck = [ "socketio" ];

  # pytestCheckHook seems to change the default log level to WARNING, but the
  # tests assert it is ERROR
  disabledTests = [ "test_logger" ];

  meta = with lib; {
    description = "Python Socket.IO server and client 4.x";
    longDescription = ''
      Socket.IO is a lightweight transport protocol that enables real-time
      bidirectional event-based communication between clients and a server.
    '';
    homepage = "https://github.com/miguelgrinberg/python-socketio/";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ graham33 ];
  };
}
