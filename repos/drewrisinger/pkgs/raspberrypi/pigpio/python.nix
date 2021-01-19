{ lib
, buildPythonPackage
, pigpio-c
}:

# Python libraries for pigpio
buildPythonPackage rec {
  pname = "pigpio-py";
  inherit (pigpio-c) src version;

  buildInputs = [ pigpio-c ];

  pythonImportsCheck = [ "pigpio" ];
  doCheck = false;  # no tests included

  meta = with lib; {
    description = "A Python library for the Raspberry Pi which allows control of the General Purpose Input Outputs (GPIO)";
    homepage = "http://abyz.me.uk/rpi/pigpio/";
    license = licenses.unlicense;
    platforms = [ "aarch64-linux" "armv7l-linux" ]; # targeted at Raspberry Pi ONLY
    maintainers = [ maintainers.drewrisinger ];
  };
}
