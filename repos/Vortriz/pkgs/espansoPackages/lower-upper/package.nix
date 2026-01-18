{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "lower-upper";
  version = "unstable-2021-11-04";

  src = fetchFromGitHub {
    owner = "anthonygraignic";
    repo = "espanso-package-lower-upper";
    rev = "9ed3737f0a6605d3d9b607eefc82efdf5e746859";
    sparseCheckout = [ "0.1.0" ];
    hash = "sha256-7ZVtI0DILjsV8cKCdIr8Z3ZjkorfL9mKoxO0Qra02G4=";
  };

  installPhase = ''
        cp -r 0.1.0 $out
    '';

  meta = {
    homepage = "https://github.com/anthonygraignic/espanso-package-lower-upper";
    license = lib.licenses.mit;
  };
}