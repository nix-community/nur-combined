{ lib
, buildPythonPackage
, fetchPypi
, pydbus
, pygobject
}:

buildPythonPackage rec {
  pname = "mumble_ptt_caps_lock_led";
  version = "1.0.1";
  
  propagatedBuildInputs = [
    pydbus
    pygobject
  ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "10bfv31g3hn5smivzfpdwqy99g80h02c9hhlx1xj189m60mpjdlb";
  };

  meta = with lib; {
    descripytion = "A python program to let the LED of your caps lock key display your mumble PTT state.";
    homepage = "https://github.com/neumantm/mumble_ptt_caps_lock_led";
    license = licenses.mit;
  };
}
