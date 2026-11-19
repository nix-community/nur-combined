{ lib
, buildPythonApplication
, setuptools
, wheel
, attrs
, black
, colorama
, iniconfig
, jwcrypto
, pyjwt
, pluggy
, py
, pytest
, requests
, six
, callPackage
, ...
}:
let
  sources = (callPackage ../../_sources/generated.nix { }).timew-sync-client;
in
buildPythonApplication {
  pname = "timew-sync-client";
  version = "0-unstable-${sources.date}";
  pyproject = true;

  inherit (sources) src;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    attrs
    black
    colorama
    iniconfig
    jwcrypto
    pluggy
    py
    pytest
    pyjwt
    requests
    six
  ];

  pythonImportsCheck = [ "timewsync" ];

  meta = with lib; {
    description = "The timewarrior synchronization client";
    homepage = "https://github.com/timewarrior-synchronize/timew-sync-client";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "timew-sync-client";
  };
}
