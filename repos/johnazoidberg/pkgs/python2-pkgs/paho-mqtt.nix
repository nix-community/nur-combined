{ lib, buildPythonPackage, fetchFromGitHub, isPy3k
, pytestrunner, pytest, mock }:
buildPythonPackage rec {
  pname = "paho-mqtt";
  version = "1.3.1";

  # No tests in PyPI tarball
  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "paho.mqtt.python";
    rev = "v${version}";
    sha256 = "034dmrihii3kgxi1g2cb2ncs6kpnbnc5arhb7i1bx1zdh4kpx9j7";
  };

  postPatch = ''
    substituteInPlace setup.py --replace "pylama" ""
    substituteInPlace setup.cfg --replace "--pylama" ""
  '';

  checkInputs = [ pytestrunner pytest ] ++ lib.optional (!isPy3k) mock;

  meta = with lib; {
    homepage = https://eclipse.org/paho;
    description = "MQTT version 3.1.1 client class";
    license = licenses.epl10;
    maintainers = with maintainers; [ mog dotlambda ];
  };
}
