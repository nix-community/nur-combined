{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "ouch";
  version = "0.2.1-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "251da6930ca8b7ee0384810086c3bf644caede3e";
    hash = "sha256-yLt9aY6hUIOdBI5bMdCs7VYFJGyD3WIkmPxvWKNCskA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
