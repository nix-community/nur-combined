{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "plover_stroke";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-3gOyP0ruZrZfaffU7MQjNoG0NUFQLYa/FP3inqpy0VM=";
  };

  # No tests available
  doCheck = false;

  disabled = pythonOlder "3.6";

  meta = with lib; {
    homepage = "https://github.com/benoit-pierre/plover_stroke";
    description = "Helper class for working with steno strokes";
    license = licenses.gpl2Plus;
  };
  passthru.updateScript = [../scripts/update-python-libraries "plover/plover-stroke.nix"];
}
