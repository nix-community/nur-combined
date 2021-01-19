{ lib
, buildPythonPackage
, fetchFromGitHub
, colorzero
, withPigpio ? true, pigpio-py
, withRpiGpio ? false, rpi-gpio
, withRpio ? false, rpio ? null
, pytestCheckHook
, mock
}:

buildPythonPackage rec {
  pname = "gpiozero";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "gpiozero";
    repo = pname;
    rev = "v${version}";
    sha256 = "17fr7bilrhrb6r7djb41g317lm864kd4bkrl22aqhk4236sqq9ym";
  };

  propagatedBuildInputs = [ colorzero ]
    ++ lib.optionals (withPigpio) [ pigpio-py ]
    ++ lib.optionals (withRpiGpio) [ rpi-gpio ]
    ++ lib.optionals (withRpio) [ rpio ] ;

  checkInputs = [ pytestCheckHook mock ];
  pythonImportsCheck = [ "gpiozero" ];
  dontUseSetuptoolsCheck = true;
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "A simple interface to GPIO devices with Raspberry Pi";
    homepage = "https://gpiozero.readthedocs.io/en/stable/";
    license = licenses.bsd3;
    maintainers = [ maintainers.drewrisinger ];
  };
}
