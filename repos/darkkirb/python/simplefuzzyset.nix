{
  callPackage,
  buildPythonPackage,
  fetchPypi,
  lib,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "simplefuzzyset";
  version = "0.0.12";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-mhsww4tq+3bGYAvdZsHB3D2FBbCC6ePUZvYPQOi34fI=";
  };

  doCheck = false;

  disabled = pythonOlder "3.6";

  meta = with lib; {
    description = "A simpler python fuzzyset implementation.";
    license = licenses.bsd3; # Unclear, author specifies OSI approved bsd license but not which
  };
  passthru.updateScript = [../scripts/update-python-libraries "python/simplefuzzyset.nix"];
}
