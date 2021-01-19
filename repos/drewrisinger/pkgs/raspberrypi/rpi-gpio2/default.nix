{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
, libgpiod
, pytestCheckHook
}:

let
  builderIsRaspberryPi = (stdenv.buildPlatform.isAarch64);
in
buildPythonPackage rec {
  pname = "rpi-gpio2";
  version = "0.3.0a3";

  src = fetchFromGitHub {
    owner = "underground-software";
    repo = "rpi.gpio2";
    rev = "v${version}";
    sha256 = "11z6g95njfn9rwcd8d2vblj8mi05bglhdiwxv5lgmq5yfc91nx7h";
  };

  propagatedBuildInputs = [ libgpiod ];

  checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "RPi.GPIO" ];
  doCheck = builderIsRaspberryPi;
  dontUsePythonImportsCheck = !doCheck; # import only works on raspberry pi

  meta = with lib; {
    description = "Compatibility layer between RPi.GPIO syntax and libgpiod semantics";
    homepage = "https://github.com/underground-software/RPi.GPIO2";
    license = licenses.gpl3Plus;
    platforms = [ "aarch64-linux" ];
  };
}
