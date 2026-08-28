{
  lib,
  buildPythonPackage,
  fetchPypi,
  cheetah,
  nose,
}:

buildPythonPackage (finalAttrs: {
  pname = "TurboCheetah";
  version = "1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-nkx+yw0GG/tYKBNj7hsJM3CD8BOotNA1Uyal2GaPRQw=";
  };

  propagatedBuildInputs = [ cheetah ];

  checkInputs = [ nose ];

  meta = {
    description = "TurboGears plugin to support use of Cheetah templates";
    homepage = "http://docs.turbogears.org/TurboCheetah";
    license = lib.licenses.mit;
  };
})
