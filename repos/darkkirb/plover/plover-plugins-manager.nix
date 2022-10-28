{
  callPackage,
  buildPythonPackage,
  fetchPypi,
  lib,
  pip,
  pkginfo,
  pygments,
  readme_renderer,
  requests,
  requests-cache,
  requests-futures,
  setuptools,
  wheel,
  pythonOlder,
}: let
  plover = callPackage ./plover {};
in
  buildPythonPackage rec {
    pname = "plover_plugins_manager";
    version = "0.7.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-/RiWbGxPtm+0mhDi0heEVb6iBKuyBm6IOq2yrj17n9s=";
    };

    doCheck = false;

    disabled = pythonOlder "3.6";
    propagatedBuildInputs = [pip pkginfo plover pygments readme_renderer requests requests-cache requests-futures setuptools wheel];

    meta = with lib; {
      description = "Plugins manager for plover";
      license = licenses.gpl2Plus;
    };
    passthru.updateScript = [../scripts/update-python-libraries "plover/plover-plugins-manager.nix"];
  }
