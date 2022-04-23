{ lib, buildPythonPackage, fetchFromGitHub, aiocoap, pycryptodomex }:

buildPythonPackage rec {
  pname = "aioairctrl";
  version = "0.2.1-git";

  src = fetchFromGitHub {
    owner = "kongo09";
    repo = "aioairctrl";
    rev = "5468b4e5ab30a08c8dd6ea14adb210f63f73191c";
    hash = "sha256-QeFt8XA7eRWgfY73nUNnbWRxLxDJbdCGzOimFUoWl0c=";
  };

  patches = [ ./0001-drop-version.patch ];
  propagatedBuildInputs = [ aiocoap pycryptodomex ];

  meta = with lib; {
    description =
      "library and commandline utilities for controlling philips air purifiers (using encrypted CoAP)";
    homepage = "https://github.com/kongo09/aioairctrl";
    license = licenses.mit;
  };
}
